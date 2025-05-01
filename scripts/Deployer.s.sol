// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTachyonForwarder} from "../src/RathFiTachyonForwarder.sol";

contract DeployRathFiForwarder is Script {
    address constant forwarderAddress = 0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e;
    address constant receiverAddress = 0xC4CE7f21f31E115E549B49116D130F0eB15dc726;
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