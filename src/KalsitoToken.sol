// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract KalsitoToken is ERC20, Ownable {
    /// @notice Constructor for the KalsitoToken contract
    /// @dev Initializes the ERC20 token with name "KalsitoToken" and symbol "KAL". Sets the contract deployer as the owner.
    constructor() ERC20("KalsitoToken", "KAL") Ownable(msg.sender) {}

    /// @notice Mints new tokens to a specified address
    /// @dev Only callable by the contract owner
    /// @param to The address to receive the newly minted tokens
    /// @param amount The number of tokens to mint (in wei)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
