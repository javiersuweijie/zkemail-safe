// Taken from: https://github.com/zkemail/email-wallet/blob/main/packages/contracts/src/utils/MailServer.sol
pragma solidity >=0.8.13;

import "forge-std/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MailServer is Ownable {
    uint16 constant rsa_modulus_chunks_len = 17;
    mapping(string => uint256[rsa_modulus_chunks_len]) verifiedMailserverKeys;

    constructor() {
        // Do dig TXT outgoing._domainkey.twitter.com to verify these.
        // This is the base 2^121 representation of that key.
        // Circom bigint: represent a = a[0] + a[1] * 2**n + .. + a[k - 1] * 2**(n * k)
        initMailserverKeys();
    }

    function initMailserverKeys() internal {
        // TODO: Create a type that takes in a raw RSA key, the bit count,
        // and whether or not its base64 encoded, and converts it to either 8 or 16 signals
        verifiedMailserverKeys["gmail.com"][0] = 1886180949733815343726466520516992271;
        verifiedMailserverKeys["gmail.com"][1] = 1551366393280668736485689616947198994;
        verifiedMailserverKeys["gmail.com"][2] = 1279057759087427731263511728885611780;
        verifiedMailserverKeys["gmail.com"][3] = 1711061746895435768547617398484429347;
        verifiedMailserverKeys["gmail.com"][4] = 2329140368326888129406637741054282011;
        verifiedMailserverKeys["gmail.com"][5] = 2094858442222190249786465516374057361;
        verifiedMailserverKeys["gmail.com"][6] = 2584558507302599829894674874442909655;
        verifiedMailserverKeys["gmail.com"][7] = 1521552483858643935889582214011445675;
        verifiedMailserverKeys["gmail.com"][8] = 176847449040377757035522930003764000;
        verifiedMailserverKeys["gmail.com"][9] = 632921959964166974634188077062540145;
        verifiedMailserverKeys["gmail.com"][10] = 2172441457165086627497230906075093832;
        verifiedMailserverKeys["gmail.com"][11] = 248112436365636977369105357296082574;
        verifiedMailserverKeys["gmail.com"][12] = 1408592841800630696650784801114783401;
        verifiedMailserverKeys["gmail.com"][13] = 364610811473321782531041012695979858;
        verifiedMailserverKeys["gmail.com"][14] = 342338521965453258686441392321054163;
        verifiedMailserverKeys["gmail.com"][15] = 2269703683857229911110544415296249295;
        verifiedMailserverKeys["gmail.com"][16] = 3643644972862751728748413716653892;

        verifiedMailserverKeys["hotmail.com"][0] = 128339925410438117770406273090474249;
        verifiedMailserverKeys["hotmail.com"][1] = 2158906895782814996316644028571725310;
        verifiedMailserverKeys["hotmail.com"][2] = 2278019331164769360372919938620729773;
        verifiedMailserverKeys["hotmail.com"][3] = 1305319804455735154587383372570664109;
        verifiedMailserverKeys["hotmail.com"][4] = 2358345194772578919713586294428642696;
        verifiedMailserverKeys["hotmail.com"][5] = 1333692900109074470874155333266985021;
        verifiedMailserverKeys["hotmail.com"][6] = 2252956899717870524129098594286063236;
        verifiedMailserverKeys["hotmail.com"][7] = 1963190090223950324858653797870319519;
        verifiedMailserverKeys["hotmail.com"][8] = 2099240641399560863760865662500577339;
        verifiedMailserverKeys["hotmail.com"][9] = 1591320380606901546957315803395187883;
        verifiedMailserverKeys["hotmail.com"][10] = 1943831890994545117064894677442719428;
        verifiedMailserverKeys["hotmail.com"][11] = 2243327453964709681573059557263184139;
        verifiedMailserverKeys["hotmail.com"][12] = 1078181067739519006314708889181549671;
        verifiedMailserverKeys["hotmail.com"][13] = 2209638307239559037039565345615684964;
        verifiedMailserverKeys["hotmail.com"][14] = 1936371786309180968911326337008120155;
        verifiedMailserverKeys["hotmail.com"][15] = 2611115500285740051274748743252547506;
        verifiedMailserverKeys["hotmail.com"][16] = 3841983033048617585564391738126779;

        verifiedMailserverKeys["ethereum.org"][0] = 119886678941863893035426121053426453;
        verifiedMailserverKeys["ethereum.org"][1] = 1819786846289142128062035525540154587;
        verifiedMailserverKeys["ethereum.org"][2] = 18664768675154515296388092785538021;
        verifiedMailserverKeys["ethereum.org"][3] = 2452916380017370778812419704280324749;
        verifiedMailserverKeys["ethereum.org"][4] = 147541693845229442834461965414634823;
        verifiedMailserverKeys["ethereum.org"][5] = 714676313158744653841521918164405002;
        verifiedMailserverKeys["ethereum.org"][6] = 1495951612535183023869749054624579068;
        verifiedMailserverKeys["ethereum.org"][7] = 974892773071523448175479681445882254;
        verifiedMailserverKeys["ethereum.org"][8] = 53117264910028079;
        verifiedMailserverKeys["ethereum.org"][9] = 0;
        verifiedMailserverKeys["ethereum.org"][10] = 0;
        verifiedMailserverKeys["ethereum.org"][11] = 0;
        verifiedMailserverKeys["ethereum.org"][12] = 0;
        verifiedMailserverKeys["ethereum.org"][13] = 0;
        verifiedMailserverKeys["ethereum.org"][14] = 0;
        verifiedMailserverKeys["ethereum.org"][15] = 0;
        verifiedMailserverKeys["ethereum.org"][16] = 0;
    }

    function setProxyOwner(address proxyAddress) public onlyOwner {
        transferOwnership(proxyAddress);
    }

    function _stringEq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function isVerified(string memory domain, uint256 index, uint256 val) public view returns (bool) {
        // Allow external queries on mapping
        if (verifiedMailserverKeys[domain][index] != val) {
            console.log(verifiedMailserverKeys[domain][index], val);
        }

        return verifiedMailserverKeys[domain][index] == val;
    }

    function editMailserverKey(string memory domain, uint256 index, uint256 val) public onlyOwner {
        verifiedMailserverKeys[domain][index] = val;
    }

    function getMailserverKey(string memory domain, uint256 index) public returns (uint256) {
        return verifiedMailserverKeys[domain][index];
    }

    // TODO: Add DNSSEC verification to add a key as well
}