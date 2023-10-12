pragma solidity >=0.8.13;

import "./EmailVerifier.sol";
import "./MailServer.sol";
import "./ISafe.sol";
import "./Enum.sol";

contract ZkEmailSafe {

    // ============================
    // Prover Constants
    // ============================
    uint16 public constant proposal_len = 4;
    uint16 public constant safe_len = 6;
    uint16 public constant email_len = 4; // TODO: this might be variable
    uint16 public constant rsa_len = 17;
    // Last two inputs are the nullifier and relayer id
    // 4 + 6 + 4 + 17 + 2 = 33

    // ============================
    // Module Constants
    // ============================
    uint16 public constant max_signers = 256;
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
    mapping (address => uint64) thresholds;
    // Safe -> Next Proposal ID
    mapping (address => uint64) nextProposalId;
    // Safe -> Proposal ID -> Proposal data
    mapping (address => mapping(uint64 => bytes)) proposals;
    // Safe -> Proposal ID -> Linked list of signers who voted
    mapping (address => mapping(uint64 => mapping(bytes32 => bytes32))) votes;

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
        nextProposalId[safe] = 0;
    }

    function propose(address safe, address to, uint256 amount, bytes calldata data, Enum.Operation operation) external returns (uint64) {
        bytes memory encoded = abi.encode(to, amount, data, operation);
        uint64 proposalId = nextProposalId[safe];
        proposals[safe][proposalId] = encoded;
        nextProposalId[safe] += 1;
        return proposalId;
    }
    
    function execute(address safe, uint64 proposalId) external returns (bool) {
        bytes storage proposalData = proposals[safe][proposalId];
        (address to, uint256 amount, bytes memory data, Enum.Operation operation) = abi.decode(proposalData, (address, uint256, bytes, Enum.Operation));

        uint64 voteCount = 0;
        bytes32 currentEmail = email_start;
        for (uint i = 0; i < max_signers; i++) {
            currentEmail = votes[safe][proposalId][email_start];
            if (currentEmail == 0x00) {
                break;
            }
            voteCount += 1;
        }

        require(voteCount >= thresholds[safe], "ZE0001");
        return ISafe(safe).execTransactionFromModule(to, amount, data, operation);
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
    function iterateSigner(address safe, bytes32 email) external view returns (bytes32) {
        return signers[safe][email];
    }
}