/*
 ░█▀▄░█▀█░▀█▀░█░█░░░█▀▀░▀█▀░█▀█░█▀█░█▀█░█▀▀░█▀▀
 ░█▀▄░█▀█░░█░░█▀█░░░█▀▀░░█░░█░█░█▀█░█░█░█░░░█▀▀
 ░▀░▀░▀░▀░░▀░░▀░▀░░░▀░░░▀▀▀░▀░▀░▀░▀░▀░▀░▀▀▀░▀▀▀
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "solmate/tokens/ERC20.sol";
import "solady/utils/ECDSA.sol";
/**
 * @title RathFiTachyonSecuredForwarder
 * @author Aniket965, Rath.Fi (Rath Finance)
 */

contract RathFiTachyonSecuredForwarder is Ownable {
    /// @notice signer for secured forwarder address.
    address public signerAddress;

    /// @dev Custom error thrown when forwarding transactions fail.
    error TachyonForwarderFailed();

    /// @dev Custom error thrown when the signature is invalid.
    error InvalidNonce();

    /// @dev Custom error thrown when the signature is invalid.
    error TachyonInvalidSignature();

    /// @dev nonce bitmap to track used nonces.
    mapping(uint256 => uint256) public nonceBitmap;

    /**
     * @notice Deploys the contract with a specified forwarder and receiver address.
     * @param _signerAddress The address which will sign the authorization.
     * @param _owner The owner of the contract.
     */
    constructor(address _signerAddress, address _owner) Ownable(_owner) {
        signerAddress = _signerAddress;
    }

    /**
     * @notice Sets the signer address.
     * @param _signerAddress The new signer address.
     */
    function setSignerAddress(address _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    /**
     * @notice Forwards a call to a target address with the specified data and value.
     * @param target The target address to forward the call to.
     * @param data The data to send in the call.
     * @param value The value to send with the call.
     * @param nonce The nonce for the transaction.
     * @param signature The signature authorizing the transaction.
     */
    function call(address target, bytes calldata data, uint256 value, uint256 nonce, bytes calldata signature)
        external
        payable
    {
        // Verify the signature
        bytes32 messageHash =
            keccak256(abi.encode("RATH_FI_CALL", block.chainid, address(this), nonce, target, data, value));

        _verifySignature(messageHash, signature, signerAddress);
        _useUnorderedNonce(nonce);

        // Forward the call
        (bool success, bytes memory returnData) = target.call{value: value}(data);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    revert(add(32, returnData), mload(returnData))
                }
            } else {
                revert TachyonForwarderFailed();
            }
        }
    }

    /**
     * @notice Forwards multiple calls to a target address with the specified data and value.
     * @param target The array of target addresses to forward the calls to.
     * @param data The array of data to send in the calls.
     * @param value The array of values to send with the calls.
     * @param nonce The nonce for the transaction.
     * @param signature The signature authorizing the transaction.
     */
    function multiCall(
        address[] calldata target,
        bytes[] calldata data,
        uint256[] calldata value,
        uint256 nonce,
        bytes calldata signature
    ) external payable {
        // Verify the signature
        bytes32 messageHash = keccak256(
            abi.encode(
                "RATH_FI_MULTI_CALL",
                block.chainid,
                address(this),
                nonce,
                abi.encode(target),
                abi.encode(data),
                abi.encode(value)
            )
        );

        _verifySignature(messageHash, signature, signerAddress);
        _useUnorderedNonce(nonce);

        // Forward the calls
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory returnData) = target[i].call{value: value[i]}(data[i]);
            
            // If the call fails, revert with the return data if available
            if (!success) {
                if (returnData.length > 0) {
                    assembly {
                        revert(add(32, returnData), mload(returnData))
                    }
                } else {
                    revert TachyonForwarderFailed();
                }
            }
        }
    }

    /**
     * @notice Withdraws stuck tokens or ETH from the contract.
     * @dev If `token` is address(0), it withdraws ETH; otherwise, it withdraws ERC-20 tokens.
     * @param token The address of the token to withdraw (use `address(0)` for ETH).
     */
    function TachyonWithdraw(address token, uint256 amount, address receiver) public onlyOwner {
        if (token == address(0)) {
            (bool success,) = payable(receiver).call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            ERC20(token).transfer(receiver, amount);
        }
    }

    /**
     * @notice Returns the bitmap positions for a given nonce.
     * @dev This function calculates the word position and bit position for a given nonce.
     * @param nonce The nonce to calculate positions for.
     * @return wordPos The word position in the bitmap.
     * @return bitPos The bit position in the word.
     */
    function bitmapPositions(uint256 nonce) private pure returns (uint256 wordPos, uint256 bitPos) {
        wordPos = uint248(nonce >> 8);
        bitPos = uint8(nonce);
    }

    /**
     * @notice Marks a nonce as used in the bitmap.
     * @dev This function flips the bit corresponding to the nonce in the bitmap.
     * @param nonce The nonce to mark as used.
     */
    function _useUnorderedNonce(uint256 nonce) internal {
        (uint256 wordPos, uint256 bitPos) = bitmapPositions(nonce);
        uint256 bit = 1 << bitPos;
        uint256 flipped = nonceBitmap[wordPos] ^= bit;

        if (flipped & bit == 0) revert InvalidNonce();
    }

    /**
     * @notice Verifies the signature of a message.
     * @param messageHash The hash of the message to verify.
     * @param signature The signature to verify.
     * @param expectedSigner The expected signer address.
     */
    function _verifySignature(bytes32 messageHash, bytes memory signature, address expectedSigner) internal view {
        if (ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), signature) != expectedSigner) {
            revert TachyonInvalidSignature();
        }
    }

    /**
     * @notice Allows the contract to receive ETH.
     */
    fallback() external payable {}
    receive() external payable {}
}
