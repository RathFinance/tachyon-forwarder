// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "solmate/tokens/ERC20.sol"; 

contract MultiSenderWrapper is Ownable {

    address public immutable MULTI_SENDER_ADDRESS = 0x8D29bE29923b68abfDD21e541b9374737B49cdAD;
    address public immutable receiverAddress;
    

    constructor(address _receiverAddress, address _owner) Ownable(_owner) {
        receiverAddress = _receiverAddress;
    }

 
    function rescue(address token) public onlyOwner {
        if (token == address(0)) {
            payable(owner()).call{value:address(this).balance}("");
        } else {
            ERC20(token).transfer(owner(), ERC20(token).balanceOf(address(this)));
        }
    }
}
