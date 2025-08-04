// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import {Script} from "forge-std/Script.sol";
import {RathFiTrustedTachyonForwarder} from "../src/RathFiTrustedTachyonForwarder.sol";

contract DeployRathFiForwarder is Script {
    address constant forwarderAddress = 0xE2C5658cC5C448B48141168f3e475dF8f65A1e3e;
    address constant receiverAddress = 0xc301626560b049a80214f948749b9909c183Cda7;
    address constant trustedRelayer = 0x4C16955d8A0DcB2e7826d50f4114990c787b21E7;
    address constant Owner = receiverAddress;
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        RathFiTrustedTachyonForwarder forwarder = new RathFiTrustedTachyonForwarder(
            receiverAddress,
            forwarderAddress,
            trustedRelayer,
            Owner
        );
        vm.stopBroadcast();
    }
}