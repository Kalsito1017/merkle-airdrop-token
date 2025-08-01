// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "lib/forge-std/src/Script.sol";

contract SplitSignature is Script {
    error __SplitSignatureScript__InvalidSignatureLength();

    /// @notice Splits a 65-byte Ethereum signature into its `v`, `r`, and `s` components.
    /// @dev Uses inline assembly to efficiently extract values from memory.
    ///      The expected signature format is: {r (32 bytes)}{s (32 bytes)}{v (1 byte)}.
    /// @param sig The full 65-byte ECDSA signature.
    /// @return v Recovery byte (27 or 28).
    /// @return r First 32 bytes of the signature.
    /// @return s Second 32 bytes of the signature.
    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        // Signature must be exactly 65 bytes long
        if (sig.length != 65) {
            revert __SplitSignatureScript__InvalidSignatureLength();
        }

        // Extract r, s, v using low-level assembly
        assembly {
            // Load r: first 32 bytes after the length prefix (offset +32)
            r := mload(add(sig, 32))
            // Load s: next 32 bytes (offset +64)
            s := mload(add(sig, 64))
            // Load v: final byte (first byte of word at offset +96)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    /// @notice Reads and parses an ECDSA signature from a file, then logs its components.
    /// @dev Expects a file `signature.txt` in the project root containing a hex-encoded signature.
    ///      Uses Forge’s `vm.readFile` and `vm.parseBytes` cheatcodes.
    ///      Useful for debugging or off-chain signature validation.
    function run() external {
        // Read signature from a local file as a string
        string memory sig = vm.readFile("signature.txt");

        // Convert the hex string into a bytes array
        bytes memory sigBytes = vm.parseBytes(sig);

        // Split signature into its ECDSA parts
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sigBytes);

        // Log values for inspection
        console.log("v value:");
        console.log(v);

        console.log("r value:");
        console.logBytes32(r);

        console.log("s value:");
        console.logBytes32(s);
    }
}
