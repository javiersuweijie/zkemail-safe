pragma solidity >=0.8.13;

import "./EmailVerifier.sol";
import "./MailServer.sol";
import "./ISafe.sol";
import "./Enum.sol";
import "./helpers/StringUtils.sol";

contract ZkEmailSafe {

    // ============================
    // Prover Constants
    // ============================
    uint16 public constant pack_size = 8;
    uint16 public constant proposal_len = 4;
    uint16 public constant safe_len = 6;
    uint16 public constant email_len = 4;
    uint16 public constant rsa_len = 17;
    // Last two inputs are the nullifier and relayer id
    // 4 + 6 + 4 + 17 + 2 = 33

    // ============================
    // Module Constants
    // ============================
    uint16 public constant max_signers = 32;
    bytes32 public constant email_start = "_";

    // ============================
    // Safe Global Variables
    // ============================
    MailServer public mailServer;
    Groth16Verifier public verifier;

    // ============================
    // Safe Scoped Variables
    // ============================
    // Safe -> Linked list of signer eamils starting
    // Email max length 31 characters
    mapping (address => mapping(bytes32 => bytes32)) signers;
    // Safe -> Number of signers required to pass a proposal
    mapping (address => uint64) public thresholds;
    // Safe -> Next Proposal ID
    mapping (address => uint64) public nextProposalId;
    // Safe -> Proposal ID -> Proposal data
    mapping (address => mapping(uint64 => bytes)) proposals;
    // Safe -> Proposal ID -> Linked list of signers who voted
    mapping (address => mapping(uint64 => mapping(bytes32 => bytes32))) votes;
    // Safe -> Proposal ID -> Executed
    mapping (address => mapping(uint64 => bool)) public executed;

    constructor (MailServer ms, Groth16Verifier v) {
        mailServer = ms;
        verifier = v;
    }

    function add_safe(uint64 threshold, bytes32[] memory emails) external {
        address safe = msg.sender;
        thresholds[safe] = threshold;
        bytes32 currentEmail = email_start;
        for (uint i = 0; i < emails.length; i++) {
            signers[safe][currentEmail] = emails[i];
            currentEmail = emails[i];
        }
    }

    function propose(address safe, address to, uint256 amount, bytes calldata data, Enum.Operation operation) external returns (uint64) {
        bytes memory encoded = abi.encode(to, amount, data, operation);
        uint64 proposalId = nextProposalId[safe];
        proposals[safe][proposalId] = encoded;
        nextProposalId[safe] += 1;
        return proposalId;
    }

    function vote(uint[2] calldata a, uint[2][2] calldata b, uint[2] calldata c, uint[33] calldata signals) external {
        // unpack from proposal
        uint[] memory packedProposal = new uint[](proposal_len);
        for (uint i = 0; i < proposal_len; i++) {
            packedProposal[i] = signals[i];
        }
        string memory proposalIdString = StringUtils.convertPackedBytesToString(packedProposal, pack_size * proposal_len, pack_size); 
        uint64 proposalId = uint64(StringUtils.stringToUint(proposalIdString));

        // unpack safe
        uint[] memory packedSafe = new uint[](safe_len);
        for (uint i = 0; i < safe_len; i++) {
            packedSafe[i] = signals[proposal_len + i];
        }
        string memory safeString = StringUtils.convertPackedBytesToString(packedSafe, pack_size * safe_len, pack_size); 
        address safe = StringUtils.toAddress(safeString);

        require(this.isSafe(safe), "Safe not found");
        require(nextProposalId[safe] > proposalId, "Proposal not found");

        // unpack from email
        uint[] memory packedEmail = new uint[](email_len);
        for (uint i = 0; i < 4; i++) {
            packedEmail[i] = signals[proposal_len + safe_len + i];
        }
        string memory email = StringUtils.convertPackedBytesToString(packedEmail, pack_size * email_len, pack_size); 
        string memory domain = StringUtils.getDomainFromEmail(email);
        bytes32 emailBytes = StringUtils.stringToBytes32(email);

        bool canSign = this.isSigner(safe, emailBytes);
        require(canSign, "Email cannot vote");

        // verify RSA
        for (uint i = 0; i < 17; i++) {
            uint p = signals[14 + i];
            require(mailServer.isVerified(domain, i, p), "RSA public key incorrect");
        }

        // verify proof
        require(verifier.verifyProof(a,b,c,signals));

        // add vote
        bytes32 currentEmail = email_start;
        for (uint i = 0; i < max_signers; i++) {
            bytes32 nextEmail = votes[safe][proposalId][currentEmail];
            require(nextEmail != emailBytes, "Signer already voted");
            if (nextEmail == 0x0000000000000000000000000000000000000000000000000000000000000000) {
                votes[safe][proposalId][currentEmail] = emailBytes;
                break;
            }
            currentEmail = nextEmail;
        }
    }
    
    function execute(address safe, uint64 proposalId) external {
        bytes storage proposalData = proposals[safe][proposalId];
        (address to, uint256 amount, bytes memory data, Enum.Operation operation) = abi.decode(proposalData, (address, uint256, bytes, Enum.Operation));

        require(!executed[safe][proposalId], "Already executed");
        require(this.voteCount(safe, proposalId) >= thresholds[safe], "Not enough votes");
        require(ISafe(safe).execTransactionFromModule(to, amount, data, operation), "Transaction failed");
        executed[safe][proposalId] = true;
    }

    function proposal(address safe, uint64 proposalId) external view returns (bytes memory) {
        return proposals[safe][proposalId];
    }

    function signerCount(address safe) external view returns (uint64) {
        bytes32 currentEmail = email_start;
        uint64 count = 0;
        for (uint i = 0; i < max_signers; i++) {
            currentEmail = signers[safe][currentEmail];
            if (currentEmail == 0x00) {
                break;
            }
            count += 1;
        }
        return count;
    }

    function proposalCount(address safe) external view returns (uint64) {
        return nextProposalId[safe];
    }

    function voteCount(address safe, uint64 proposalId) external view returns (uint64) {
        uint64 count = 0;
        bytes32 currentEmail = email_start;
        for (uint i = 0; i < max_signers; i++) {
            currentEmail = votes[safe][proposalId][currentEmail];
            if (currentEmail == 0x0000000000000000000000000000000000000000000000000000000000000000) {
                break;
            }
            count += 1;
        }
        return count;
    }

    function isSigner(address safe, bytes32 email) external view returns (bool) {
        bytes32 currentEmail = email_start;
        for (uint i = 0; i < max_signers; i++) {
            currentEmail = signers[safe][currentEmail];
            if (currentEmail == 0x00) {
                break;
            }
            if (keccak256(abi.encodePacked(currentEmail)) == keccak256(abi.encodePacked(email))) {
                return true;
            }
        }
        return false;
    }

    function isSafe(address safe) external view returns (bool) {
        return signers[safe][email_start] != 0x0000000000000000000000000000000000000000000000000000000000000000;
    }
    
    function iterateSigner(address safe, bytes32 email) external view returns (bytes32) {
        return signers[safe][email];
    }

    function iterateVotes(address safe, uint64 proposalId, bytes32 email) external view returns (bytes32) {
        return votes[safe][proposalId][email];
    }
}