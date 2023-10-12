// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

import "../ZkEmailSafe.sol";
import "../EmailVerifier.sol";
import "../MailServer.sol";

contract ZkEmailSafeTest is Test {
    ZkEmailSafe zkEmailSafe;
    MailServer mailServer;
    Groth16Verifier emailVerifier;
    address constant owner = 0x0000000000000000000000000000000000011111;

    function setUp() public {
        mailServer = new MailServer();
        emailVerifier = new Groth16Verifier();
        zkEmailSafe = new ZkEmailSafe(mailServer, emailVerifier);

        console.log(address(mailServer));
        console.log(address(emailVerifier));
        console.log(address(zkEmailSafe));

        bytes32 email1 = hex"6A617669657240746573742E636F6D0000000000000000000000000000000000";
        bytes32 email2 = hex"62617669657240746573742E636F6D0000000000000000000000000000000000";
        uint[2] memory emails = [uint256(email1), uint256(email2)];
   }

    function testSignerCount() public {
        zkEmailSafe.signerCount(address(0x0000000000000000000000000000000000011111));
    }

    // function testSetup() public {
    //     bytes32 email1 = hex"00000000000000000000000000000000006A617669657240746573742E636F6D";
    //     bytes32 email2 = hex"000000000000000000000000000000000062617669657240746573742E636F6D";
    //     uint[2] memory emails = [uint256(email1), uint256(email2)];
    //    IZkEmailSafe zkEmailSafe2 = IZkEmailSafe(vyperDeployer.deployContract("zkEmailSafe", abi.encode("test.com", 0, 1, 2, emails)));
    //     uint owners = zkEmailSafe.owners();
    //     require(owners == 2);
    //     uint256 owner = zkEmailSafe.iterateOwner(0);
    //     console.log(owner);
    //     // bytes32 x =  keccak256("javier@test.com");
    //     // console.logBytes32(x);

    //     owner = zkEmailSafe.iterateOwner(owner);
    //     console.log(owner);
    //     // bool result = zkEmailSafe.isOwner("javier@test.com");
    //     // require(result == true);
    // }

    // function testExecute() public {
    //     bytes32 result = zkEmailSafe.execute(1, address(zkEmailSafe), 10, "123", uint(Operation.Call));
    //     console.logBytes32(result);
    // }
}