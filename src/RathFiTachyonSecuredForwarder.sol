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
 * @title RathFiTachyonSecuredForwarder
 * @author Aniket965, Rath.Fi (Rath Finance)
 */
contract RathFiTachyonSecuredForwarder is Ownable {

    /// @notice signer for secured forwarder address.
    address public signerAddress;

    /// @dev Custom error thrown when forwarding transactions fail.
    error TachyonForwarderFailed();

    /**
     * @notice Deploys the contract with a specified forwarder and receiver address.
     * @param _signerAddress The address which will sign the authorization.
     * @param _owner The owner of the contract.
     */
    constructor(address _signerAddress, address _owner) Ownable(_owner) {
        signerAddress = _signerAddress;
    }

    function call(
        address target,
        bytes calldata data,
        uint256 value,
        bytes calldata signature,
        uint256 nonce
    ) external payable onlyOwner {
        // Verify the signature
        bytes32 messageHash = keccak256(abi.encodePacked(block.chainid,nonce,target, data, value));
        require(recoverSigner(messageHash, signature) == signerAddress, "Invalid signature");

        // Forward the call
        (bool success, ) = target.call{value: value}(data);
        require(success, "Forwarding failed");
    }

    /**
     * @notice Withdraws stuck tokens or ETH from the contract.
     * @dev If `token` is address(0), it withdraws ETH; otherwise, it withdraws ERC-20 tokens.
     * @param token The address of the token to withdraw (use `address(0)` for ETH).
     */
    function TachyonWithdraw(address token, uint256 amount, address receiver) public onlyOwner {
        if (token == address(0)) {
            (bool success, ) = payable(receiver).call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            ERC20(token).transfer(receiver, amount);
        }
    }

    /**
     * @notice Forwards all calldata and value to `forwarderAddress`.
     */
    fallback() external payable {}

    /**
     * @notice Allows the contract to receive ETH.
     */
    receive() external payable {}
}