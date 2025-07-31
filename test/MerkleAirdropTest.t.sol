// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Test, console} from "lib/forge-std/src/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {KalsitoToken} from "src/KalsitoToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    KalsitoToken public token;
    address gasPayer;
    bytes32 public Root =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 public proofOne =
        0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proofOne, proofTwo];

    uint256 userPrivKey;
    function setUp() public {
        token = new KalsitoToken();
        airdrop = new MerkleAirdrop(Root, token);
        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPrivKey) = makeAddrAndKey("user");
    }
    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
        uint256 endingBalance = token.balanceOf(user);

        console.log(endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
