// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Script} from "lib/forge-std/src/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {KalsitoToken} from "src/KalsitoToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);
    /// @notice Deploys both a new `KalsitoToken` and a `MerkleAirdrop` contract, then transfers tokens to the airdrop.
    /// @dev Broadcasts the deployment transaction using Foundry's `vm.startBroadcast()`.
    ///      Mints tokens to the token owner, and transfers a fixed amount to the airdrop contract.
    /// @return airdrop The newly deployed MerkleAirdrop contract.
    /// @return token The newly deployed KalsitoToken contract.
    function deployMerkleAirdrop()
        public
        returns (MerkleAirdrop airdrop, KalsitoToken token)
    {
        vm.startBroadcast(); // Begin broadcasting a transaction

        // Deploy ERC-20 token contract
        token = new KalsitoToken();

        // Deploy the airdrop contract, passing the Merkle root and token address
        airdrop = new MerkleAirdrop(
            s_merkleRoot, // Merkle root used for claim verification
            IERC20(address(token)) // Token used for the airdrop
        );

        // Mint tokens to the token owner
        token.mint(token.owner(), AMOUNT_TO_TRANSFER);

        // Transfer minted tokens to the airdrop contract
        IERC20(token).transfer(address(airdrop), AMOUNT_TO_TRANSFER);

        vm.stopBroadcast(); // End broadcast
    }

    /// @notice Executes the deployment of KalsitoToken and MerkleAirdrop contracts.
    /// @dev Simply calls `deployMerkleAirdrop()` and returns the deployed contract addresses.
    /// @return airdrop The deployed MerkleAirdrop instance.
    /// @return token The deployed KalsitoToken instance.
    function run()
        external
        returns (MerkleAirdrop airdrop, KalsitoToken token)
    {
        return deployMerkleAirdrop();
    }
}
