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
 * @title RathFiTachyonRelay
 * @notice A contract that relays transactions to a specified address.
 * @dev blockedAddress is used to prevent any transaction sent to reward token contract directly
 * @author Aniket965, Rath.Fi (Rath Finance)
 */
contract RathFiTachyonRelay is Ownable {

    /// @notice Address to which all transactions cant be relayed to.
    address public immutable blockedAddress;

    /// @notice Receiver address for token withdrawals.
    address public immutable receiverAddress;

    /// @dev Custom error thrown when forwarding transactions fail.
    error TachyonRelayFailed();
    
    /// @dev Custom error thrown when relay address is blocked.
    error BlockedAddress();

    /**
     * @notice Deploys the contract with a specified forwarder and receiver address.
     * @notice there is blockedAddress to prevent any transaction sent to token contract directly
     * @param _receiverAddress The address to which tokens can be withdrawn.
     * @param _blockedAddress The contract address to which transactions are blocked.
     * @param _owner The owner of the contract.
     */
    constructor(address _receiverAddress, address _blockedAddress, address _owner) Ownable(_owner) {
        receiverAddress = _receiverAddress;
        blockedAddress = _blockedAddress;
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
     * @notice Relays a transaction to a specified address.
     * @param relayAddress The address to which the transaction is relayed.
     * @param data The transaction data.
     */
    function relay(
        address relayAddress,
        bytes calldata data
    ) external payable {

        if(relayAddress == blockedAddress) revert BlockedAddress();
        
        (bool success,) = payable(relayAddress).call{value: msg.value}(data);
        
        if (!success) revert TachyonRelayFailed();
    }

    fallback() external payable {}

    /**
     * @notice Allows the contract to receive ETH.
     */
    receive() external payable {}
}