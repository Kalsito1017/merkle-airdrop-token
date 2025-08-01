// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    /// @title MerkleAirdrop
    /// @notice Contract for distributing ERC20 tokens using a Merkle tree-based airdrop

    using SafeERC20 for IERC20; // Use SafeERC20 library for IERC20 token operations

    /// @notice Error thrown when a provided Merkle proof is invalid
    error MerkleAirdrop__InvalidMerkleProof(); // Custom error for invalid Merkle proof

    /// @notice Error thrown when an account tries to claim more than once
    error MerkleAirdrop__AlreadyClaimed(); // Custom error for already claimed airdrop
    error MerkleAirdrop__InvalidSignature(); // Custom error for invalid signature

    address[] i_claimers; // Array to store addresses of claimers

    bytes32 private immutable i_merkleRoot; // Merkle root for verifying claims

    IERC20 private immutable i_airdropToken; // ERC20 token to be airdropped

    mapping(address => bool) private s_hasClaimed; // Mapping to track if an address has claimed
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    event Claimed(address account, uint256 amount); // Event emitted on successful claim

    /// @notice Constructor to initialize the Merkle root and airdrop token
    /// @param merkleRoot The Merkle root for the airdrop
    /// @param airdropToken The ERC20 token to be distributed
    constructor(
        bytes32 merkleRoot,
        IERC20 airdropToken
    ) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot; // Set the Merkle root
        i_airdropToken = airdropToken; // Set the airdrop token
    }
    /// @param merkleProof The Merkle proof to verify eligibility
    function claim(
        address account, // The address claiming the airdrop
        uint256 amount, // The amount to claim
        bytes32[] calldata merkleProof, // The Merkle proof for verification
        uint8 v, // The v parameter for ECDSA signature
        bytes32 r, // The r parameter for ECDSA signature
        bytes32 s // The s parameter for ECDSA signature
    ) external {
        if (s_hasClaimed[account]) {
            // Check if the account has already claimed
            revert MerkleAirdrop__AlreadyClaimed(); // Revert if already claimed
        }
        //check the signature
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }
        s_hasClaimed[account] = true; // Mark the account as claimed
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount))) // Compute the leaf node for Merkle proof
        );
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            // Verify the Merkle proof
            revert MerkleAirdrop__InvalidMerkleProof(); // Revert if proof is invalid
        }
        s_hasClaimed[account] = true; // Mark the account as claimed (redundant, but present in original)
        emit Claimed(account, amount); // Emit the Claimed event
        i_airdropToken.transfer(account, amount); // Transfer the airdrop tokens to the account
    }
    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address ActualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return ActualSigner == account;
    }
    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(MESSAGE_TYPEHASH, AirdropClaim(account, amount))
                )
            );
    }
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
