// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "ds-test/test.sol";

import "../ZkEmailSafe.sol";
import "../EmailVerifier.sol";
import "../MailServer.sol";

import "../helpers/StringUtils.sol";

contract ZkEmailSafeTest is Test {
    ZkEmailSafe zkEmailSafe;
    MailServer mailServer;
    Groth16Verifier emailVerifier;
    address constant owner = 0x0000000000000000000000000000000000011111;
    address constant safe1 = 0x0000000000000000000000000000000000000001;
    address constant safe2 = 0x0000000000000000000000000000000000000010;

    bytes32 constant email1 = hex"6A617669657240746573742E636F6D0000000000000000000000000000000000";
    bytes32 constant email2 = hex"6A61766965722E73752E7765696A696540676D61696C2E636F6D000000000000";

    function setUp() public {
        mailServer = new MailServer();
        emailVerifier = new Groth16Verifier();
        zkEmailSafe = new ZkEmailSafe(mailServer, emailVerifier);

        // console.log(address(mailServer));
        // console.log(address(emailVerifier));
        // console.log(address(zkEmailSafe));

        bytes32[] memory emails = new bytes32[](2);
        emails[0] = email1;
        emails[1] = email2;

        vm.startPrank(safe1);
        // console.log(msg.sender);
        zkEmailSafe.add_safe(1, emails);
        vm.stopPrank();
    }

    function testAddSafeCorrectly() public {
        bytes32[] memory emails = new bytes32[](2);
        emails[0] = email1;
        emails[1] = email2;
        
        bool isNotSafe = !zkEmailSafe.isSafe(safe2);
        assertTrue(isNotSafe);

        vm.startPrank(safe2);
        zkEmailSafe.add_safe(2, emails);
        vm.stopPrank();

        bool isSafe = zkEmailSafe.isSafe(safe2);
        assertTrue(isSafe);


        uint64 count = zkEmailSafe.signerCount(safe2);
        assertEq(count, 2);

        bytes32 email = zkEmailSafe.iterateSigner(safe2, zkEmailSafe.email_start());
        assertEq32(email, email1);

        email = zkEmailSafe.iterateSigner(safe2, email);
        assertEq32(email, email2);

        bool isSigner = zkEmailSafe.isSigner(safe2, email2);
        assertTrue(isSigner);

        uint64 threshold = zkEmailSafe.thresholds(safe2);
        assertEq(threshold, 2);
    }

    function testAddProposal() public {
        uint64 id = zkEmailSafe.propose(safe1, owner, 1000, hex"", Enum.Operation.Call);
        assertEq(id, 0);

        uint64 count = zkEmailSafe.proposalCount(safe1);
        assertEq(count, 1);

        bytes memory proposal = zkEmailSafe.proposal(safe1, id);
        (address to, uint256 amount, bytes memory data, Enum.Operation operation) = abi.decode(proposal, (address, uint256, bytes, Enum.Operation));

        assertEq(to, owner);
        assertEq(amount, 1000);
        assertEq(data.length, 0);
        assertEq(uint256(operation), uint256(Enum.Operation.Call));

        bool executed = zkEmailSafe.executed(safe1, id);
        assertFalse(executed, "Should not be executed");

        // should fail to execute since there are no votes
        vm.expectRevert("Not enough votes");
        zkEmailSafe.execute(safe1, id);
    }

    function testVote() public {
        zkEmailSafe.propose(safe1, owner, 1000, hex"", Enum.Operation.Call);

        uint[2] memory a = [0x0754cb9d5be521b6d2d6d577985f321309062b03ffaf64bb1db671b97918ca68, 0x097915d59bf00c76e2a2acbc5523a18863321717c48d7a0eb8467c13368ea530];
        uint[2][2] memory b = [[0x0201e73f9510454885acfe54982d1179788c3c51176ac5ec1c07997614834509, 0x08c0374772d37647459ad66695a6a2cbc6629b6a15d4cd1e86ad716d80ea97a1],[0x10a36cd4956b48b0265422d1bcdd312f01b00bf0e5bde505574dd470e4b899e1, 0x226b787e8fb1872f21d168c9c57252d730ba6073fcc3ec1c3344910e31628f85]];
        uint[2] memory c = [0x1304d8c1e737c6a9c78bb5d952d21198f46e818450dc39554247898174901385, 0x2f4786454fbb8f759acd60982c27ed8b998dd1557c5d4b2c903ea43c0cb5b99d];
        uint[33] memory signals = [uint(48),0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000003030303030307830,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000000000000000003130,0x000000000000000000000000000000000000000000000000732e72656976616a,0x00000000000000000000000000000000000000000000000065696a6965772e75,0x000000000000000000000000000000000000000000000000632e6c69616d6740,0x0000000000000000000000000000000000000000000000000000000000006d6f,0x000000000000000000000000000000000195d4c106145000c13aeeedd678b05f,0x0000000000000000000000000000000001ed8b83fdb773d1730ddda2066cd5b3,0x000000000000000000000000000000000167d6a9a16d4a3d07bc6eb492951b22,0x00000000000000000000000000000000019fe05891ab1a0a71b2d56a0c416515,0x000000000000000000000000000000000043c08e0917cd795cc9d25636606145,0x00000000000000000000000000000000007f0e932deb0d915b589a2a7b70939e,0x0000000000000000000000000000000000fe907aa3ad716e2baec1f6e0bed784,0x000000000000000000000000000000000031d03ea0bc27c0ecb7b1ec6cda1688,0x00000000000000000000000000000000007c32a76308aae634320642d63fe2e0,0x000000000000000000000000000000000021af28eda0ad14a0008d7706a6da3b,0x0000000000000000000000000000000000cdd527713c044381c33b02c444087c,0x0000000000000000000000000000000001684d2c2d1a38fd978fc63ad37e7f98,0x00000000000000000000000000000000000198ab996377df7a009eee7764b238,0x000000000000000000000000000000000116a054e98ea9aed0ecabe226f1c4c9,0x0000000000000000000000000000000001b280bf4a87667e656cd83d4a007de6,0x000000000000000000000000000000000063f20dd1707613702fb797e979b478,0x0000000000000000000000000000000000009edbd2293d6192a84a7b4c5c699d,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000001];

        zkEmailSafe.vote(a, b, c, signals);
        uint64 votes = zkEmailSafe.voteCount(safe1, 0);
        assertEq(votes, 1);

        vm.expectRevert("Signer already voted");
        zkEmailSafe.vote(a, b, c, signals);
    }

    function testUtils() public {
        uint[2] memory a = [0x0754cb9d5be521b6d2d6d577985f321309062b03ffaf64bb1db671b97918ca68, 0x097915d59bf00c76e2a2acbc5523a18863321717c48d7a0eb8467c13368ea530];
        uint[2][2] memory b = [[0x0201e73f9510454885acfe54982d1179788c3c51176ac5ec1c07997614834509, 0x08c0374772d37647459ad66695a6a2cbc6629b6a15d4cd1e86ad716d80ea97a1],[0x10a36cd4956b48b0265422d1bcdd312f01b00bf0e5bde505574dd470e4b899e1, 0x226b787e8fb1872f21d168c9c57252d730ba6073fcc3ec1c3344910e31628f85]];
        uint[2] memory c = [0x1304d8c1e737c6a9c78bb5d952d21198f46e818450dc39554247898174901385, 0x2f4786454fbb8f759acd60982c27ed8b998dd1557c5d4b2c903ea43c0cb5b99d];
        uint[33] memory signals = [uint(48),0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000003030303030307830,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000003030303030303030,0x0000000000000000000000000000000000000000000000000000000000003130,0x000000000000000000000000000000000000000000000000732e72656976616a,0x00000000000000000000000000000000000000000000000065696a6965772e75,0x000000000000000000000000000000000000000000000000632e6c69616d6740,0x0000000000000000000000000000000000000000000000000000000000006d6f,0x000000000000000000000000000000000195d4c106145000c13aeeedd678b05f,0x0000000000000000000000000000000001ed8b83fdb773d1730ddda2066cd5b3,0x000000000000000000000000000000000167d6a9a16d4a3d07bc6eb492951b22,0x00000000000000000000000000000000019fe05891ab1a0a71b2d56a0c416515,0x000000000000000000000000000000000043c08e0917cd795cc9d25636606145,0x00000000000000000000000000000000007f0e932deb0d915b589a2a7b70939e,0x0000000000000000000000000000000000fe907aa3ad716e2baec1f6e0bed784,0x000000000000000000000000000000000031d03ea0bc27c0ecb7b1ec6cda1688,0x00000000000000000000000000000000007c32a76308aae634320642d63fe2e0,0x000000000000000000000000000000000021af28eda0ad14a0008d7706a6da3b,0x0000000000000000000000000000000000cdd527713c044381c33b02c444087c,0x0000000000000000000000000000000001684d2c2d1a38fd978fc63ad37e7f98,0x00000000000000000000000000000000000198ab996377df7a009eee7764b238,0x000000000000000000000000000000000116a054e98ea9aed0ecabe226f1c4c9,0x0000000000000000000000000000000001b280bf4a87667e656cd83d4a007de6,0x000000000000000000000000000000000063f20dd1707613702fb797e979b478,0x0000000000000000000000000000000000009edbd2293d6192a84a7b4c5c699d,0x0000000000000000000000000000000000000000000000000000000000000000,0x0000000000000000000000000000000000000000000000000000000000000001];
        // test verification
        bool verified = emailVerifier.verifyProof(a,b,c,signals);
        assertTrue(verified);

        // unpack safe
        uint[] memory packedSafe = new uint[](6);
        for (uint i = 0; i < 6; i++) {
            packedSafe[i] = signals[4 + i];
        }
        string memory safeString = StringUtils.convertPackedBytesToString(packedSafe, 8 * 6, 8); 
        address safe = StringUtils.toAddress(safeString);
        assertEq(safe, safe1);

        // unpack from email
        uint[] memory packedEmail = new uint[](4);
        for (uint i = 0; i < 4; i++) {
            packedEmail[i] = signals[10 + i];
        }
        string memory email = StringUtils.convertPackedBytesToString(packedEmail, 8 * 4, 8); 
        assertEq(email, "javier.su.weijie@gmail.com");

        string memory domain = StringUtils.getDomainFromEmail(email);
        assertEq(domain, "gmail.com");

        bytes32 emailBytes = StringUtils.stringToBytes32(email);
        assertEq(emailBytes, email2);

        // unpack from proposal
        uint[] memory packedProposal = new uint[](4);
        for (uint i = 0; i < 4; i++) {
            packedProposal[i] = signals[i];
        }
        string memory proposalIdString = StringUtils.convertPackedBytesToString(packedProposal, 8, 8); 
        uint256 proposalId = StringUtils.stringToUint(proposalIdString);
        assertEq(uint64(proposalId), 0);


        // verify RSA
        for (uint i = 0; i < 17; i++) {
            uint p = signals[14 + i];
            assertTrue(mailServer.isVerified(domain, i, p));
        }
    }

    // function testExecute() public {
    //     bytes32 result = zkEmailSafe.execute(1, address(zkEmailSafe), 10, "123", uint(Operation.Call));
    //     console.logBytes32(result);
    // }
}
