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
    // IERC20 USDCcontract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
     function setUp() public {
        vm.startPrank(owner);
        uint mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/xypdsCZYrlk6oNi93UmpUzKE9kmxHy2n", 17042264);
        vm.selectFork(mainnet);
        treasury = new Treasury(50, 50);
        vm.makePersistent(address(treasury));
        vm.stopPrank();
    } 

    function testDeposit()public {
        vm.startPrank(owner);
        console.log("Owner balance before StableCoin deposit:", IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).balanceOf(owner));
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).safeApprove(address(treasury), 1000 * 1e18); 
        treasury.depositDAI(address(0x6B175474E89094C44Da98b954EedeAC495271d0F), 1000 * 1e18);
        // treasury.depositUSDT();
        // treasury.depositUSDC();
        console.log("Owner balance After StableCoin deposit:", IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F).balanceOf(owner));
        vm.stopPrank();
    }

    function testOptimizeYeild() public {
        testDeposit();
        vm.startPrank(owner);
        treasury.OptimizeYield(10 * 1e18, IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F));
        vm.warp(block.timestamp + 1704067199);
        treasury.withdrawLiquidity();
        treasury.withdrawFunds(0x6B175474E89094C44Da98b954EedeAC495271d0F, 1e18);
        vm.stopPrank();
    }

   
}