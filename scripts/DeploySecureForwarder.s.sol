// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTachyonSecuredForwarder} from "../src/RathFiTachyonSecuredForwarder.sol";
import {ICREATE3Factory} from "../src/interface/ICreate3Factory.sol";

contract DeployRathFiSecuredForwarder is Script {
    address constant signerAddress = 0x42F5d19865CD35feb1c610f94b5DBB5c05cdF6A0;
    address constant Owner = signerAddress;
    
    ICREATE3Factory public ICREATE;
    function run() external {
        ICREATE = ICREATE3Factory(0xF2B6544589ab65E731883A0244cbEFe5735322c5);
        
        uint256 deployerPrivateKey = vm.envUint("KEY");
        vm.startBroadcast(deployerPrivateKey);

         address deployed = ICREATE.deploy(
            keccak256("RathFiTachyonSecuredForwarder-AcrossBot"),
            abi.encodePacked(
                type(RathFiTachyonSecuredForwarder).creationCode,
                abi.encode(signerAddress, Owner)
            )
        );
        vm.stopBroadcast();
    }
}