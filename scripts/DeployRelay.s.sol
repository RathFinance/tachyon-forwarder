// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTachyonRelay} from "../src/RathFiTachyonRelay.sol";


contract DeployRathFiRelay is Script {
    address constant blockedAddress = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
    address constant receiverAddress = 0x092772CdEF109fEd26052E79B952Ac5404f1Ed21;
    address constant Owner = receiverAddress;
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        RathFiTachyonRelay relay = new RathFiTachyonRelay(
            receiverAddress,
            blockedAddress,
            Owner
        );
        vm.stopBroadcast();
    }
}