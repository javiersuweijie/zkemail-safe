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
        verifiedMailserverKeys["gmail.com"][0] = 2107195391459410975264579855291297887;
        verifiedMailserverKeys["gmail.com"][1] = 2562632063603354817278035230349645235;
        verifiedMailserverKeys["gmail.com"][2] = 1868388447387859563289339873373526818;
        verifiedMailserverKeys["gmail.com"][3] = 2159353473203648408714805618210333973;
        verifiedMailserverKeys["gmail.com"][4] = 351789365378952303483249084740952389;
        verifiedMailserverKeys["gmail.com"][5] = 659717315519250910761248850885776286;
        verifiedMailserverKeys["gmail.com"][6] = 1321773785542335225811636767147612036;
        verifiedMailserverKeys["gmail.com"][7] = 258646249156909342262859240016844424;
        verifiedMailserverKeys["gmail.com"][8] = 644872192691135519287736182201377504;
        verifiedMailserverKeys["gmail.com"][9] = 174898460680981733302111356557122107;
        verifiedMailserverKeys["gmail.com"][10] = 1068744134187917319695255728151595132;
        verifiedMailserverKeys["gmail.com"][11] = 1870792114609696396265442109963534232;
        verifiedMailserverKeys["gmail.com"][12] = 8288818605536063568933922407756344;
        verifiedMailserverKeys["gmail.com"][13] = 1446710439657393605686016190803199177;
        verifiedMailserverKeys["gmail.com"][14] = 2256068140678002554491951090436701670;
        verifiedMailserverKeys["gmail.com"][15] = 518946826903468667178458656376730744;
        verifiedMailserverKeys["gmail.com"][16] = 3222036726675473160989497427257757;

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

        verifiedMailserverKeys["proton.me"][0] = 913891206902747244664747020968558259;
        verifiedMailserverKeys["proton.me"][1] = 1972901582512682675310311312776703330;
        verifiedMailserverKeys["proton.me"][2] = 1271254850995070111689795451119553905;
        verifiedMailserverKeys["proton.me"][3] = 761251125734672353504177040036773981;
        verifiedMailserverKeys["proton.me"][4] = 2649236452477034537871075340909610458;
        verifiedMailserverKeys["proton.me"][5] = 797204999605065995847033273845334469;
        verifiedMailserverKeys["proton.me"][6] = 431665553429246829372283307811261199;
        verifiedMailserverKeys["proton.me"][7] = 2519265340557762696665849280444169595;
        verifiedMailserverKeys["proton.me"][8] = 614771124440053389931039527792329052;
        verifiedMailserverKeys["proton.me"][9] = 346547961474255468698682697091329228;
        verifiedMailserverKeys["proton.me"][10] = 1644056136146630059529017048340409920;
        verifiedMailserverKeys["proton.me"][11] = 1435425770606909017673442738893123308;
        verifiedMailserverKeys["proton.me"][12] = 429440991622236380985084713724774430;
        verifiedMailserverKeys["proton.me"][13] = 1333616918559527589215725487503491629;
        verifiedMailserverKeys["proton.me"][14] = 824096634501694007840550414810418446;
        verifiedMailserverKeys["proton.me"][15] = 646624441958089088676457473935543531;
        verifiedMailserverKeys["proton.me"][16] = 3236208936482879880513152955132688;
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