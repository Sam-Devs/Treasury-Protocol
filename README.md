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

## Contribution
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