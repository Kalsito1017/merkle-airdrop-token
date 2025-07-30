// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract KalsitoToken {
    constructor() ERC20("KalsitoToken", "KAL") Ownable(msg.sender) {}
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
