// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/protocol-v2/contracts/interfaces/ILendingPool.sol";
// import "../lib/compound-protocol/contracts/CErc20.sol";
import "../contracts/interfaces/Interface.sol";


/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details


contract Treasury {
    using SafeERC20 for IERC20;
    struct depositordetails {
        uint AmountDeposited;
        IERC20 Token;
    }

    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC contract address
    IERC20 private constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT contract address
    IERC20 private constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI contract address
    IUniswapV2Router02 private constant UNISWAP_ROUTER = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap Router contract address
    IAAVE private constant AAVE_LENDING_POOL = IAAVE(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9); // AAVE lending pool contract address
     ICERC20 private constant CUSDT = ICERC20(0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9); //CUSDT compound address
    address private owner;
    mapping(address => depositordetails)Depositor; //Tracks deposit details
    uint private highestAllocation;
     uint private lowestAllocation;

    

     constructor(uint _highestAllocation, uint _lowestAllocation) {
        owner = msg.sender;
        highestAllocation = _highestAllocation;
        lowestAllocation = _lowestAllocation;
    }

    //deposit token to this contract
    function deposit(address _tokenAddress, uint256 amount) external {
        //call approve function on erc20 before deposit
        require(owner == msg.sender, 'not authorized');
        if(_tokenAddress == address(USDC) || _tokenAddress == address(USDT) || _tokenAddress == address(DAI)){
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        Depositor[msg.sender].AmountDeposited += amount;
        Depositor[msg.sender].Token = IERC20(_tokenAddress);     
        }
        else{
            revert("Token not accepted");
        }                
    }
    
    //swap deposited Token for usdt, check for highest returning APY and distributes funds to the protocols based on the best APY returns.
    function OptimizeYeild(uint _amount) external {
        require(owner == msg.sender, "not owner");
        require(_amount <= Depositor[msg.sender].AmountDeposited);
     //calculate highest yeilding APY then assign ratio based on the level of APY.  
        uint aaveAllocationPercent;
        uint compoundAllocationPercent;
        uint AaveAPY = getAaveAPY() * 1000;
        uint CompoundAPY = getCompoundAPY() * 1000;
            if(AaveAPY > CompoundAPY){
                aaveAllocationPercent = highestAllocation;
                compoundAllocationPercent = lowestAllocation;
            }else if(AaveAPY < CompoundAPY){
                aaveAllocationPercent = lowestAllocation;
                compoundAllocationPercent = highestAllocation;
            }else if(AaveAPY == CompoundAPY){
                aaveAllocationPercent = 50;
                compoundAllocationPercent = 50;
            }
         //approve uniswap to spend token
        IERC20 token = Depositor[msg.sender].Token;
        if(token == USDC || token == DAI) {
        address[] memory uniswapPath = new address[](2);
        uniswapPath[0] = address(token);
        uniswapPath[1] = address(USDT); 
          // swap here 
        IERC20(token).safeApprove(address(UNISWAP_ROUTER), _amount);
        UNISWAP_ROUTER.swapExactTokensForTokens(_amount, 100, uniswapPath, address(this), block.timestamp + 2591999); //current block.timestamp + one month (can be adjusted) ;
        }
        uint amountTodeposit = USDT.balanceOf(address(this));
        uint aaveAllocation = (aaveAllocationPercent * amountTodeposit)/100;
        uint compoundAllocation = amountTodeposit - aaveAllocation;
         // aave interaction
        // approve aave to spend usdt token
        USDT.safeApprove(address(AAVE_LENDING_POOL), aaveAllocation);
        IAAVE(AAVE_LENDING_POOL).deposit(address(USDT), aaveAllocation, address(this), 0);
        USDT.balanceOf(address(this));

    //     // compound interaction
        // approve the compound CUSDT address to spend usdt.
        IERC20(address(USDT)).safeApprove(address(CUSDT), compoundAllocation);     
       CUSDT.mint(compoundAllocation);
    }

    function withdrawLiquidity() external {
        require(owner == msg.sender, 'only owner');
      //withdraw from aave  
        IAAVE(AAVE_LENDING_POOL).withdraw(address(USDT), type(uint256).max, owner);     
      //withdraw from compound
        USDT.balanceOf(address(this));
        uint amountToredeem = CUSDT.balanceOf(address(this));
        // CUSDT.approve(address(CUSDT), amountToredeem);
        CUSDT.redeem(amountToredeem);
        USDT.balanceOf(address(this));
        address underlyingToken = (CUSDT).underlying();
        IERC20(underlyingToken).safeTransfer(msg.sender, IERC20(underlyingToken).balanceOf(address(this)));
    }
    function setAllocationRatio(uint _highestAllocation, uint _lowestAllocation) external {
        require(owner == msg.sender, 'not authorized');
        highestAllocation = _highestAllocation;
        lowestAllocation = _lowestAllocation;
    }
    function getAaveAPY() internal view returns (uint) {
       ILendingPoolAddressesProvider provider = ILendingPoolAddressesProvider(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); // Aave V2 mainnet address provider
        ILendingPool lendingPool = ILendingPool(provider.getLendingPool());
        DataTypes.ReserveData memory data = lendingPool.getReserveData(address(USDT));
        uint liquiidityRate = data.currentLiquidityRate;
        return (liquiidityRate)/1e27; //to convert to percentage from ray unit.
    }

    function getCompoundAPY() internal view returns (uint256) {
        ICompound compound = ICompound(address(CUSDT));
        uint256 currentSupplyRate = compound.supplyRatePerBlock();
        return (currentSupplyRate * 2102400)/1e18; // blocks per year // to convert to percentage. 
    }

receive() external payable {}

}