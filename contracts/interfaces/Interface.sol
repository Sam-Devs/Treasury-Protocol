// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
interface ISwapRouter {
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

interface IAAVE {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

interface ICompound {
    function balanceOf(address owner) external view returns (uint256 balance);
    function underlying() external view returns (address);
    function supplyRatePerBlock() external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function getSupplyRate(uint utilization) external view returns (uint64);
    function supply(address asset, uint amount) external;
    function withdraw(address asset, uint amount) external;

}

interface ICERC20 {
     function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
     function balanceOf(address owner) external view returns (uint);
     function underlying()external view returns(address);
}

