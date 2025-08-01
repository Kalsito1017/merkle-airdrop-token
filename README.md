# 🌿 Merkle Airdrop Token - KalsitoToken

A smart contract system for secure and gas-efficient ERC-20 token airdrops using **Merkle proofs** and EIP-712 signature verification.  
Built with **Foundry**, leveraging OpenZeppelin, Murky, and foundry-devops for a modern Solidity development workflow.

---

## 📌 Overview

This project deploys a custom ERC-20 token called **`KalsitoToken`**, alongside a **MerkleAirdrop** contract that enables eligible users to claim tokens by submitting Merkle proofs and optionally signed EIP-712 messages.

---

## 🧱 Components

### 🪙 `KalsitoToken.sol`
- ERC-20 token with minting capability  
- Secure and compatible with OpenZeppelin standards

### 🎁 `MerkleAirdrop.sol`
- Verifies claims via Merkle tree proofs  
- Uses OpenZeppelin’s `ECDSA` and `EIP712` for signature verification  
- Prevents double-claiming  
- Uses minimal on-chain storage for gas efficiency

### 📜 Scripts
- `DeployMerkleAirdrop.s.sol`: Deploys token & airdrop contracts and funds the airdrop  
- `Interact.s.sol`: Reads signatures, splits them, and calls claim functions

### 🧪 Tests
- Located in `test/` folder  
- Cover Merkle proof verification, claim logic, signature checks, and reentrancy
