// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RathFiTachyonForwarder.sol";

contract RathFiTachyonForwarderTest is Test {
    RathFiTachyonForwarder forwarder;
    address owner = address(0xdef1);
    address receiver = address(0xBEEF);
    address forwarderTarget = address(0xCAFE);
    address testUser = address(0xDEAD);

    function setUp() public {
        forwarder = new RathFiTachyonForwarder(receiver, forwarderTarget, owner);
    }

    function testDeployment() public {
        assertEq(forwarder.forwarderAddress(), forwarderTarget);
        assertEq(forwarder.receiverAddress(), receiver);
        assertEq(forwarder.owner(), owner);
    }

    function testFallbackForwarding() public {
        vm.deal(address(testUser), 1 ether); // Fund contract

        vm.prank(testUser);
        (bool success, ) = address(forwarder).call{value: 0.5 ether}(hex"beef");
        assertTrue(success);
        assertEq(address(forwarderTarget).balance, 0.5 ether);
    }

    function testWithdrawETH() public {
        vm.deal(address(forwarder), 1 ether);

        vm.prank(owner);
        forwarder.TachyonWithdraw(address(0));

        assertEq(address(owner).balance, 1 ether);
    }
}
