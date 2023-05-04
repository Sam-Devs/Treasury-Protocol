// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "forge-std/Test.sol";
import "contracts/Treasury.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract TreasuryTest is Test {
    using SafeERC20 for IERC20;
    Treasury treasury;
    address owner = 0x748dE14197922c4Ae258c7939C7739f3ff1db573;
    IERC20 USDCcontract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
     function setUp() public {
        vm.startPrank(owner);
        uint mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/xypdsCZYrlk6oNi93UmpUzKE9kmxHy2n", 17042264);
        vm.selectFork(mainnet);
        treasury = new Treasury(70, 30);
        vm.makePersistent(address(treasury));
        vm.stopPrank();
    } 

    function testDeposit()public {
        vm.startPrank(owner);
        // uint balance = IERC20(USDCcontract).balanceOf(owner);
        // console.log(balance);
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).safeApprove(address(treasury), 3000); 
        // uint allowance = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).allowance(owner, address(treasury));
        // console.log(allowance);
        treasury.deposit(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48), 3000);
        // console.log(IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).balanceOf(address(treasury)));
        vm.stopPrank();
    }

    function testOptimizeYeild() public {
        testDeposit();
        vm.startPrank(owner);
        treasury.OptimizeYeild(3000);
        vm.warp(block.timestamp + 1704067199);
        treasury.withdrawLiquidity();
        console.log(IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).balanceOf(owner));
        vm.stopPrank();
    }

   
}