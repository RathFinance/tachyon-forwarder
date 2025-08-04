// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTachyonSecuredForwarder} from "../src/RathFiTachyonSecuredForwarder.sol";
import {ICREATE3Factory} from "../src/interface/ICreate3Factory.sol";

contract DeployRathFiSecuredForwarder is Script {
    address constant signerAddress = 0x9ADA24F01D4a35E1f7ca8704082a4bC676845155;
    address constant Owner = 0xd86eDedF1b757879C3b00929cD14AcA58262eEe8;
    
    ICREATE3Factory public ICREATE;
    function run() external {
        ICREATE = ICREATE3Factory(0xF2B6544589ab65E731883A0244cbEFe5735322c5);
        
        uint256 deployerPrivateKey = vm.envUint("KEY");
        vm.startBroadcast(deployerPrivateKey);

         address deployed = ICREATE.deploy(
            keccak256("RathFiTachyonSecuredForwarder-AcrossSolver"),
            abi.encodePacked(
                type(RathFiTachyonSecuredForwarder).creationCode,
                abi.encode(signerAddress, Owner)
            )
        );
        vm.stopBroadcast();
    }
}