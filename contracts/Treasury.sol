// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/protocol-v2/contracts/interfaces/ILendingPool.sol";
import "../contracts/interfaces/Interface.sol";

contract Treasury{
    using SafeERC20 for IERC20;
    struct depositordetails {
        uint AmountDeposited;
        IERC20 Token;
    }

    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC Mainnet contract address
    IERC20 private constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT Mainnet contract address
    IERC20 private constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI Mainnet contract address
    ISwapRouter private constant UNISWAP_ROUTER = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564); // UniswapV3 Router Mainnet contract address
    IAAVE private constant AAVE_LENDING_POOL = IAAVE(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2); // AAVE V3 lending pool Mainnet contract address
     ICompound private constant CUSDC = ICompound(0xc3d688B66703497DAA19211EEdff47f25384cdc3); //CUSDc V3 Mainnet address

    // IERC20 private USDC; // USDC Mock
    // IERC20 private USDT; // USDT Mock
    // IERC20 private DAI; // DAI Mock;
    // ISwapRouter private constant UNISWAP_ROUTER = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564); // UniswapV3 Router Mainnet/testnet contract address
    // IAAVE private constant AAVE_LENDING_POOL = IAAVE(0x0b913A76beFF3887d35073b8e5530755D60F78C7); // AAVE V3 lending pool testnet contract address
    //  ICompound private constant CUSDC = ICompound(0xF25212E676D1F7F89Cd72fFEe66158f541246445); //CUSDc V3 testnet address
    address private owner;
    uint private aaveAllocationPercent;
    uint private compoundAllocationPercent;
    mapping(address=> mapping(address => depositordetails))Depositor; //Tracks deposit details

    

    //set ratio to be distributed to defi protocols
     constructor(uint _aaveAllocationPercent, uint _compoundAllocationPercent) {
        require(_aaveAllocationPercent + _compoundAllocationPercent == 100, 'cap at 100');
        owner = msg.sender;
        aaveAllocationPercent = _aaveAllocationPercent;
        compoundAllocationPercent = _compoundAllocationPercent;
    }

    //deposit Stable coin to this contract
    function depositUSDC(address _tokenAddress, uint amount)external {
         //call approve function on erc20 before deposit
         require(owner == msg.sender, 'not authorized');
         require(_tokenAddress == address(USDC), 'token not accepted');
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        Depositor[_tokenAddress][msg.sender].AmountDeposited += amount;
        Depositor[_tokenAddress][msg.sender].Token = IERC20(_tokenAddress);
    }

    function depositUSDT(address _tokenAddress, uint amount)external {
         //call approve function on erc20 before deposit
         require(owner == msg.sender, 'not authorized');
         require(_tokenAddress == address(USDT), 'token not accepted');
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        Depositor[_tokenAddress][msg.sender].AmountDeposited += amount;
        Depositor[_tokenAddress][msg.sender].Token = IERC20(_tokenAddress);
    }

    function depositDAI(address _tokenAddress, uint amount)external{
         //call approve function on erc20 before deposit
         require(owner == msg.sender, 'not authorized');
         require(_tokenAddress == address(DAI), 'token not accepted');
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        Depositor[_tokenAddress][msg.sender].AmountDeposited += amount;
        Depositor[_tokenAddress][msg.sender].Token = IERC20(_tokenAddress);
    }



    //swap deposited Token for usdt, and distributes funds to the protocols based on the best on ratio set.
    function OptimizeYield(uint _amount, IERC20 token) external {
        require(owner == msg.sender, "not owner");
        require(_amount <= Depositor[address(token)][msg.sender].AmountDeposited, 'invalid');
        require(Depositor[address(token)][msg.sender].Token == token, 'invalid address');
        //distribute funds baseds on ratio specified at deployment point/ or ratio set     
        //approve uniswap to spend token    
        //interaction for if Token is USDC, based on ratio, a fraction is swapped for USDT and deposited in AAve while the rest is deposited in Compound;
        if(token == USDC) {
        uint amountTodeposit = _amount;
        uint aaveAllocation = (aaveAllocationPercent * amountTodeposit)/100;
        uint compoundAllocation = amountTodeposit - aaveAllocation; 
        // Swap here using uniswapV3Router, grant approval then swap
        IERC20(token).safeApprove(address(UNISWAP_ROUTER), aaveAllocation);
        ExactInputSingleParams memory data = ExactInputSingleParams({tokenIn : address(USDC), tokenOut : address(USDT), fee : 3000, recipient : address(this), deadline : block.timestamp + 300, amountIn : aaveAllocation, amountOutMinimum : 100, sqrtPriceLimitX96: 0});
        uint swappedAmountToaave = UNISWAP_ROUTER.exactInputSingle(data);
        
        // Approve aave to spend usdt token and deposit USDT to protocol
        USDT.safeApprove(address(AAVE_LENDING_POOL), swappedAmountToaave);
        IAAVE(AAVE_LENDING_POOL).supply(address(USDT), swappedAmountToaave, address(this), 0);

        // Approve the compound CUSDC address to spend USDC and supply liquidity to compound.
        IERC20(address(USDC)).safeApprove(address(CUSDC), compoundAllocation);     
        CUSDC.supply(address(USDC), compoundAllocation);   
        }
        //Interaction if token is USDT, a fraction of USDT is swapped for USDC based on ratio and USDT is deposited to AAVE while USDC is supplied to compound
        else if (token == USDT){
        uint amountTodeposit = _amount;
        uint aaveAllocation = (aaveAllocationPercent * amountTodeposit)/100;
        uint compoundAllocation = amountTodeposit - aaveAllocation;

        //Approve uniswap to spend USDT and swap for USDC.
        IERC20(token).safeApprove(address(UNISWAP_ROUTER), compoundAllocation);
        ExactInputSingleParams memory data = ExactInputSingleParams({tokenIn : address(USDT), tokenOut : address(USDC), fee : 500, recipient : address(this), deadline : block.timestamp + 300, amountIn : compoundAllocation, amountOutMinimum : 0, sqrtPriceLimitX96: 0});
        uint amountToCOMpound = UNISWAP_ROUTER.exactInputSingle(data);
        
        //Approve Aave and deposit USDT into the pool
        USDT.safeApprove(address(AAVE_LENDING_POOL), aaveAllocation);
        IAAVE(AAVE_LENDING_POOL).supply(address(USDT), aaveAllocation, address(this), 0);

        //Approve compound and deposit into the pool.
        IERC20(address(USDC)).safeApprove(address(CUSDC), amountToCOMpound);     
        CUSDC.supply(address(USDC), amountToCOMpound);  
        }
        //Interaction if token is DAI, dai is swapped for both USDC and USDT and are deposited into AAVE and compound respectively.
        else if (token == DAI) {
        uint amountTodeposit = _amount;
        uint aaveAllocation = (aaveAllocationPercent * amountTodeposit)/100;
        uint compoundAllocation = amountTodeposit - aaveAllocation; 

        //Approve and swap a fraction of DAI for USDT
        IERC20(token).safeApprove(address(UNISWAP_ROUTER), amountTodeposit);
        ExactInputSingleParams memory data = ExactInputSingleParams({tokenIn : address(DAI), tokenOut : address(USDT), fee : 3000, recipient : address(this), deadline : block.timestamp + 300, amountIn : aaveAllocation, amountOutMinimum : 100, sqrtPriceLimitX96: 0});
        uint amountToAAVE = UNISWAP_ROUTER.exactInputSingle(data);

        //Appprove and deposit swapped USDT in Aave;
        USDT.safeApprove(address(AAVE_LENDING_POOL), amountToAAVE);
        IAAVE(AAVE_LENDING_POOL).supply(address(USDT), amountToAAVE, address(this), 0);
        
        //Approve and swap the remaining fraction of DAI for USDC
        ExactInputSingleParams memory data2 = ExactInputSingleParams({tokenIn : address(DAI), tokenOut : address(USDC), fee : 3000, recipient : address(this), deadline : block.timestamp + 300, amountIn : compoundAllocation, amountOutMinimum : 100, sqrtPriceLimitX96: 0});
        uint amountToCompound = UNISWAP_ROUTER.exactInputSingle(data2);
        
        //Deposit swapped USDC into the pool
        IERC20(address(USDC)).safeApprove(address(CUSDC), amountToCompound);     
        CUSDC.supply(address(USDC), amountToCompound); 
        }   
    }


    function withdrawLiquidity() external {
        require(owner == msg.sender, 'only owner');
      //withdraw from aave  
        IAAVE(AAVE_LENDING_POOL).withdraw(address(USDT), type(uint256).max, address(this));     
      //withdraw from compound
        uint amountToredeem = CUSDC.balanceOf(address(this));
        CUSDC.withdraw(address(USDC), amountToredeem);
    }

    //sets Allocation ratio
    function setAllocationRatio(uint _aaveAllocationPercent, uint _compoundAllocationPercent) external {
        require(owner == msg.sender, 'not authorized');
        aaveAllocationPercent = _aaveAllocationPercent;
        compoundAllocationPercent = _compoundAllocationPercent;
    }

    //withdraws deposited funds
    function withdrawFunds(address _tokenAddress, uint256 amount) external{
        require(owner == msg.sender, 'not authorized');
        if(_tokenAddress == address(USDC) || _tokenAddress == address(USDT) || _tokenAddress == address(DAI)){       
        IERC20(_tokenAddress).safeTransfer(msg.sender, amount);
            //Update Amount deposited;
            if (amount > Depositor[_tokenAddress][msg.sender].AmountDeposited){
                Depositor[_tokenAddress][msg.sender].AmountDeposited = 0;
            }else{
                Depositor[_tokenAddress][msg.sender].AmountDeposited -= amount;
            }
        }
        else{
            revert("Token absent");
        }   
    }
  
  //Only necessary to initialize mock Addresses, it will be taken off on deployment to mainnet and addresses will be saved as constant;
  //This will not be included the read me file
//   function setAddresses(IERC20 _usdc, IERC20 _usdt, IERC20 _dai)external {
//     require(msg.sender == owner, 'not authorized');
//       USDC = _usdc;
//       USDT = _usdt;
//       DAI = _dai;
//   }
receive() external payable {}

}
