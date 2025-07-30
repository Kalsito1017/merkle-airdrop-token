// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {KalsitoToken} from "src/KalsitoToken.sol";

contract MakeMerkle is Script {
    function run() public {
        vm.startBroadcast();
    }
}
