/*
 ░█▀▄░█▀█░▀█▀░█░█░░░█▀▀░▀█▀░█▀█░█▀█░█▀█░█▀▀░█▀▀
 ░█▀▄░█▀█░░█░░█▀█░░░█▀▀░░█░░█░█░█▀█░█░█░█░░░█▀▀
 ░▀░▀░▀░▀░░▀░░▀░▀░░░▀░░░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀▀░▀▀▀
*/ 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "solmate/tokens/ERC20.sol"; 

/**
 * @title RathFiTachyonForwarder
 * @author Aniket965, Rath.Fi (Rath Finance)
 */
contract RathFiTachyonForwarder is Ownable {

    /// @notice Address to which all forwarded transactions will be sent.
    address public forwarderAddress;

    /// @notice Receiver address for token withdrawals.
    address public receiverAddress;

    /// @dev Custom error thrown when forwarding transactions fail.
    error TachyonForwarderFailed();

    /**
     * @notice Deploys the contract with a specified forwarder and receiver address.
     * @param _receiverAddress The address to which tokens can be withdrawn.
     * @param _forwarderAddress The contract that will receive forwarded transactions.
     * @param _owner The owner of the contract.
     */
    constructor(address _receiverAddress, address _forwarderAddress, address _owner) Ownable(_owner) {
        receiverAddress = _receiverAddress;
        forwarderAddress = _forwarderAddress;
    }

    /**
     * @notice Withdraws stuck tokens or ETH from the contract.
     * @dev If `token` is address(0), it withdraws ETH; otherwise, it withdraws ERC-20 tokens.
     * @param token The address of the token to withdraw (use `address(0)` for ETH).
     */
    function TachyonWithdraw(address token) public onlyOwner {
        if (token == address(0)) {
            (bool success, ) = payable(owner()).call{value: address(this).balance}("");
            require(success, "ETH transfer failed");
        } else {
            ERC20(token).transfer(owner(), ERC20(token).balanceOf(address(this)));
        }
    }

    /**
     * @notice Forwards all calldata and value to `forwarderAddress`.
     */
    fallback() external payable {
        address target = forwarderAddress;
        bool success;
        assembly {
            let ptr := mload(0x40) // Load free memory pointer
            let size := calldatasize()
            calldatacopy(ptr, 0, size) // Copy calldata to memory
            success := call(gas(), target, callvalue(), ptr, size, 0, 0) // Forward call
        }
        if (!success) {
            revert TachyonForwarderFailed();
        }
    }

    /**
     * @notice Allows the contract to receive ETH.
     */
    receive() external payable {}
}