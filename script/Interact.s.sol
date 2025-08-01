//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Script} from "lib/forge-std/src/Script.sol";

contract Interact is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"YOUR HEX!";
    error Interact__InvalidSignatureLength();

    /// @notice Claims an airdrop from a given MerkleAirdrop contract address using a predefined signature.
    /// @dev Splits the ECDSA signature into (v, r, s), and sends the claim transaction via `vm.startBroadcast()`.
    /// @param airdrop The address of the deployed MerkleAirdrop contract.
    function claimAirdrop(address airdrop) public {
        vm.startBroadcast(); // Begin transaction broadcast (Forge-specific cheatcode)

        // Split the preloaded SIGNATURE constant into components
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        // Call claim on the MerkleAirdrop contract
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT);

        vm.stopBroadcast(); // Stop broadcasting after transaction
    }

    /// @notice Splits a 65-byte Ethereum signature into its `v`, `r`, and `s` components.
    /// @dev Uses low-level inline assembly to parse the ECDSA signature.
    /// @param signature A standard 65-byte Ethereum signature.
    /// @return v Recovery byte (27 or 28).
    /// @return r First 32 bytes of the signature.
    /// @return s Second 32 bytes of the signature.
    function splitSignature(
        bytes memory signature
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        // Signature must be exactly 65 bytes
        if (signature.length != 65) {
            revert Interact__InvalidSignatureLength();
        }

        // Inline assembly for efficient decoding
        assembly {
            // Load r (first 32 bytes after length prefix)
            r := mload(add(signature, 0x20))
            // Load s (next 32 bytes)
            s := mload(add(signature, 0x40))
            // Load v (final byte, part of the last word)
            v := byte(0, mload(add(signature, 0x60)))
        }

        return (v, r, s);
    }

    /// @notice Finds the most recent deployment of MerkleAirdrop and calls the claim function.
    /// @dev Uses foundry-devops `DevOpsTools.get_most_recent_deployment()` based on current chain ID.
    function run() external {
        // Fetch last deployed MerkleAirdrop address for this chain
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );

        // Call airdrop claim logic with fetched address
        claimAirdrop(mostRecentlyDeployed);
    }
}
