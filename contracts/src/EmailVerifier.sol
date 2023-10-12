// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 16010876489116809031696289088016892683780788783153279693038785688762545920626;
    uint256 constant deltax2 = 4806297485183998108077155203699246810408614715386784471613408066660577678524;
    uint256 constant deltay1 = 11381230674885933048704671982409501124170989673366534574698231341552148390374;
    uint256 constant deltay2 = 5786109477474107348714994877182915864063278802248327163168276695388059732779;

    
    uint256 constant IC0x = 19220451138168855138491373532689461638638129127317819309518082285519930479528;
    uint256 constant IC0y = 7592391347175709295173445585139550585826621084559087104802494517947974594975;
    
    uint256 constant IC1x = 1599236428741980293879516944973886377303373031576669963340508382696182824943;
    uint256 constant IC1y = 5099312313952492238529544303453415004286690559966389402709578674946726143141;
    
    uint256 constant IC2x = 17733927886506037913904465466768935368063667636631048312826161564854252526115;
    uint256 constant IC2y = 9418784868359891792449729707107162687297011145931150645533712237881714102323;
    
    uint256 constant IC3x = 1657130808493590006426301856446833286605446988557614560771735564013836044793;
    uint256 constant IC3y = 3332439046787423935207061159169892452314440244908777034815987864066900152266;
    
    uint256 constant IC4x = 15564837292659357470527302066151295884090942738919833593978559670407174086468;
    uint256 constant IC4y = 14341363678480762018590118365943715755097373653738881653369707140279522770412;
    
    uint256 constant IC5x = 21605137469661078449649769911031084506213806865150403824955429722058399715860;
    uint256 constant IC5y = 20114068279346876687331339471113412566287635911746394965550156825980386612504;
    
    uint256 constant IC6x = 17377067484387980902040871188877932424144889945550174787629668887704248102660;
    uint256 constant IC6y = 3365384695503541221375659411943299662598722674377038790495677498893515089516;
    
    uint256 constant IC7x = 21129699534639450821857010716945149127173130447643673453190140537179186658831;
    uint256 constant IC7y = 11420231557530068067588079523244505302325972051506152183160133832446421567690;
    
    uint256 constant IC8x = 7434380038747138477570298525991818473292048475202541818889902084501056300548;
    uint256 constant IC8y = 4943687635144934408291801788073681316453274201337384114763189387584528382004;
    
    uint256 constant IC9x = 14745693501387008606346024049640490340292415436408376555117977749707390169985;
    uint256 constant IC9y = 5213295664870823318878033705350671318000785437325991699565572516261352589381;
    
    uint256 constant IC10x = 7754345433435545109776226433661928199820253953687268816199561012755409509333;
    uint256 constant IC10y = 10215792595564933660229982753566436573619706993383155877759312358065130966978;
    
    uint256 constant IC11x = 1568442411940362431213785894898464140313558460650588809592423660527993781399;
    uint256 constant IC11y = 20924589945999339738617478636431543152882184033223190619352926669664565297096;
    
    uint256 constant IC12x = 6138582574993775587892978823404260078953490211045571724860657495225378204948;
    uint256 constant IC12y = 19949256155251959125078364129837019310633514349650551192854323533099809185993;
    
    uint256 constant IC13x = 10466783320847988795484808140495324887266961031346947217033728267674725599350;
    uint256 constant IC13y = 10538281294129028608545030552095100610480912823434768944543093093638932437543;
    
    uint256 constant IC14x = 13806429511807485891848209303025110299055122311531956975132517082741605942707;
    uint256 constant IC14y = 21778630934211094008831737629618241503358986518406051413492417558790847548890;
    
    uint256 constant IC15x = 6585021922070321763580266504046575524292319565796042337308349388045650427000;
    uint256 constant IC15y = 9709119430656540939734500464284537534730394030295797283254801847229421082396;
    
    uint256 constant IC16x = 14915458793846032240188397238510000583998432908903738782084435191888326557887;
    uint256 constant IC16y = 1706771489301331343636254107398737429865783311715093446756748498870068118170;
    
    uint256 constant IC17x = 15823813267603604360314502338303615881999734495237787995529621267682764187291;
    uint256 constant IC17y = 18498336589832125862519374261548398501309287969016148035571688727811614427179;
    
    uint256 constant IC18x = 3575137956190717105853719110539437342492711676560470495096299386278194012472;
    uint256 constant IC18y = 16590012440991510520740645547050279871071230444151459675363520952036124466804;
    
    uint256 constant IC19x = 13657061043680106464711553134090928141623051110024350514627296532506722752083;
    uint256 constant IC19y = 13895516335073069150810539000263331499519014935717949277654898299903457107087;
    
    uint256 constant IC20x = 14959327254439463784894046882856449055539378327320248955336688568119794051861;
    uint256 constant IC20y = 21051018373261076077043379628719950504914458400894454974142305626709712758900;
    
    uint256 constant IC21x = 1674476652045263857019441077635455849401551672915112164995026097594800433668;
    uint256 constant IC21y = 1983465443084853154154001432391917097442254615185100634411804028380125732393;
    
    uint256 constant IC22x = 16231404248393526464241707207443355262790467610777708734544745466256963710922;
    uint256 constant IC22y = 1217295745255736658857250472923498020317410012942901216204420286380173346420;
    
    uint256 constant IC23x = 18206025446416249820107928007823297921611483511666487467542072269276624234333;
    uint256 constant IC23y = 15890902866529393620954810599219368151360643138817865919214113072333425414054;
    
    uint256 constant IC24x = 16562118778859452785443722420146038628486836047562280032969626827808412195170;
    uint256 constant IC24y = 9871019487998501120937378459383845847126748198243922107145048251550014206684;
    
    uint256 constant IC25x = 5255303360536003818530371593593292268831276596025389650252390464850105303833;
    uint256 constant IC25y = 19023526794112922392275355764447702024514022885554333615355686283427813655604;
    
    uint256 constant IC26x = 7039938190270004484073018423448402713263821437041250829922716558280981397337;
    uint256 constant IC26y = 13739850916480943414105703145752807400669781421444826310595648123925070632562;
    
    uint256 constant IC27x = 5029005481201807403733853723611493522782930619065764779041524234858002190699;
    uint256 constant IC27y = 3639022776895737254422544224193970625190478257358317220482392350595986738342;
    
    uint256 constant IC28x = 2884557996645078584267131766103681907149585594132073488654668831938017484928;
    uint256 constant IC28y = 1730728555876064918150548173691379576590816427730581775128510054868645851594;
    
    uint256 constant IC29x = 6423795059782053882154159566656158288575241277710908382236653285847449451459;
    uint256 constant IC29y = 18180998593897861305893929788693432980963979805048283004065461274083794673896;
    
    uint256 constant IC30x = 18244656098275648733878677350261602409965821016192864779765396512225790110283;
    uint256 constant IC30y = 12642965499304282590351652411147174291024710156960722482291394280122849997249;
    
    uint256 constant IC31x = 6259761453149717114030437097631974790423138802407724151674560283937425782895;
    uint256 constant IC31y = 1924174992656370798283888759108165361462910068286124044883881633885718513036;
    
    uint256 constant IC32x = 1623687465358774548033724458950752485434700724372920960905370437231733969877;
    uint256 constant IC32y = 20903061032751793967964491851271770626848623058420835796230976783231085564253;
    
    uint256 constant IC33x = 8026775405650635172307528497097222060655172945009850542671401042577570305270;
    uint256 constant IC33y = 19880743680371844205165139200224179100837687953421410824521543495729513713211;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[33] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
