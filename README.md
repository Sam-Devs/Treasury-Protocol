# Treasury Protocol
 The Treasury contract is a platform that accepts token deposit, distributes these deposits across defi protocols (Aave and compound finance in this case) in order to provide liquidity while token owners earn interest on the liquidity provided. The treasury accepts stable coin deposit such as DAI, USDC and USDT only.

 The treasury smart contract should be able to receive funds in the form of USDC or any other stablecoin. These funds should then be distributed among the different protocols and swapped for either USDT or DAI, which are other stablecoins commonly used in DeFi protocols.
 
 The ratio of funds to be distributed can be set by the owner of the smart contract and can be changed dynamically after the deployment to the test/mainnet chains. This means that the smart contract should be flexible enough to adjust the ratio of funds allocated to different protocols based on changing market conditions.
 
 The smart contract should also be able to withdraw the funds from the liquidity pools or DeFi protocols, either fully or partially, as needed. Finally, the percentage yield of all the protocols should be calculated and aggregated.

 ## Features
 - DAI/USDC/USDT Deposit.
 - Interacts with UNISWAP to swap tokens to USDT.
 - Optimize yeild by allocating to defi protocols based on their current APY.
 - Returns on Liquidity provided with minimal risk.
 - Project utilizes Hardhat and Foundry integration.

## Setup
```shell
 git clone https://github.com/Sam-Devs/Treasury-Protocol.git
 cd Treasury-Protocol
 npm install  or yarn update
 forge install & forge update
```

## Testing work Flow
- Approves Treasury contract to spend token
- Deposit Token 
- Calls Optimize yeild function 
- Warps time for a year
- Calls withdraw liquidity function.

```shell
 forge test
```

NOTE : Pending the time aave protocol-v2 will be updated, Change the pragma solidity version of the following after 'forge install' to pragma solidity ^0.8.9; or higher

 lib/protocol-v2/contracts/interfaces/ILendingPool.sol
 lib/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol
 lib/protocol-v2/contracts/protocol/libraries/types/DataTypes.sol

```
## Testing work Flow
Utilized Foundry and forked the Mainnet before carrying out the following : 
- Approve Treasury contract to spend token
- Deposit Token 
- Calls Optimize yield function 
- Warps time for a year
- Calls withdraw liquidity function.

```shell
 forge test
```
## Deployment
- Set The ratio that determines how the deposited token would be distributed to defi protocols (in this case, AAVE & compound) as constructor arguments.

## Scripting
- Foundry Solidity scripting

## Functions
### Deposits
```
function depositUSDC(address _tokenAddress, uint amount)external {}
function depositUSDT(address _tokenAddress, uint amount)external {}
function depositDAI(address _tokenAddress, uint amount)external{}
```
- Parameters are the stable token contract address and amount to deposit
- Allows for the deposit of USDT, USDC, DAI
- Checks if the token address passed in is either of the three tokens before allowing deposits.

### OptimizeYield( )
```
function OptimizeYield(uint _amount, IERC20 token) external {}
```
- It allows for interaction with aave protocol and compound finance while supplying liquidity to their pools, liquiidty distribution to this pool is based on allocation ratio set
- Only owner modification (Single owner per Treasury contract)
- USDT is Deposited to AAVE while USDC is deposited to Compound.
- When a user decides to optimize yeild on USDC deposit, there will be interaction with UNISWAP a fraction of amount to deposit (aave's allocation) is swapped for USDT and deposited to aave while the remaining USDC is deposited to compound.
- in the case of USDT deposit, a fraction is swapped to USDC for deposit to AAVE while the other USDT fraction is deposited to USDT
- in the case of DAI deposit, Dai deposit is swapped using uniswap for USDT and USDC to be deposited to AAVE and compound respectively.

## WithdrawLiquidity( )
```
function withdrawLiquidity() external {}
```
- Withdraws liquidity provided to AAVE and compound protocol
- only owner modification 

## WithdrawFunds ( )
```
 function withdrawFunds(address _tokenAddress, uint256 amount) external{}
```
- Withdraws funds desposited into the treasury contract

## setAllocationRatio ( )
```
 function setAllocationRatio(uint _aaveAllocationPercent, uint _compoundAllocationPercent) external {}
```
- Asides setting the allocation ratio at the constructor level, owner can dynamically adjust the ratio to be allocated to protocols.
