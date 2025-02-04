// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTachyonForwarder} from "../src/RathFiTachyonForwarder.sol";

contract DeployRathFiForwarder is Script {
    address constant forwarderAddress = 0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e;
    address constant receiverAddress = 0x2635f1FE263B2976D0c0994b3689a5099D80cc5c;
    address constant Owner = receiverAddress;
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        RathFiTachyonForwarder forwarder = new RathFiTachyonForwarder(
            receiverAddress,
            forwarderAddress,
            Owner
        );
        vm.stopBroadcast();
    }
}