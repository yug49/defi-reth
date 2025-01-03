# rETH Integration

### Foundry

```shell
cd foundry
forge build
```

# TODO:

- comment exercises and tests

### 1 - Introduction

- [ ] Overview
- [ ] Objectives
  - [ ] What is the course about
  - [ ] Who is it for?
  - [ ] What will you learn?
- [ ] Prerequisites
- [ ] Project setup

### 2 - Understanding rETH

- [ ] 2.1 - What is rETH
  - [x] [ETH staking](./notes/eth-stake.png)
  - [x] [What problem does Rocket Pool solve?](./notes/rocket-pool.png)
  - [x] [What is rETH?](./notes/reth.png)
  - [x] [Value of rETH](./notes/reth.png)
  - [x] What can you do with rETH?
    - Examples - Uniswap V3, Curve, Balancer, Aura, Aave V3, EigenLayer
  - [x] How to obtain rETH and redeem ETH
    - [ ] browser - Rocket pool, Uniswap, Curve V2, DEX aggregator
    - [ ] Availability and exchange rates
- [x] [rETH contract overview](./notes/reth-flow.png)
- [ ] 2.3 - Exchange rates
  - [ ] How exchange rate is calculated
    - [x] [Math](./notes/reth-exchange-rate.png)
    - [ ] Comments on code
      - [`RocketDepositPool.deposit`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/deposit/RocketDepositPool.sol#L90-L127)
      - [`RocketTokenRETH.mint`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/token/RocketTokenRETH.sol#L94-L103)
      - [`RocketTokenRETH.burn`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/token/RocketTokenRETH.sol#L106-L123)
    - [ ] Foundry exercises (TODO: comments + README)
      - [ ] Calculate exchange rate from ETH to rETH
      - [ ] Calculate exchange rate from rETH to ETH
- [ ] Availability and deposit delay
  - [ ] Foundry exercises (TODO: comments + README)
    - [ ] Get availability
    - [ ] Get block delay settings from storage
    - [ ] Get last user deposit block from storage
- [ ] 2.4 - Swapping between ETH and rETH
  - [ ] Foundry exercises (TODO: comments + README)
    - [ ] Rocket Pool
      - Note on deposit fee
      - Note on deposit block delay
    - [ ] Uniswap V3
      - Note on arbitrage (mint rETH -> swap rETH to ETH on Uniswap V3)
    - [ ] Balancer V2
    - [ ] Curve (skip)

### 3 - DeFi integrations

- [ ] Leverage rETH
  - [ ] [What is AAVE](./notes/aave.png)
    - Overcollateralized loan
    - LTV
    - health factor
  - [ ] [What is leverage](./notes/leverage.png)
    - Example
  - [ ] [Math](./notes/max-leverage.png)
  - [ ] [Flash leverage math](./notes/flash-lev.png)
    - TODO?: price limits based on borrow amount
  - [ ] Foundry exercises
- [ ] Provide liquidity to Balancer / Aura
  - [ ] What is Balancer (TODO: excalidraw)
    - [ ] Why add liquidity to Balancer?
  - [ ] What is Aura (TODO: excalidraw)
  - TODO: how are the rewards distributed?
  - TODO: contract interactions
  - [ ] Foundry exercises (TODO: comments + README)
    - [ ] Balancer liquidity
    - [ ] Aura liquidity and claim rewards
- [ ] Rocket Pool NAV oracle (TODO: excalidraw)
  - TODO: why points to RETH.getExchangeRate
  - [ ] What is NAV oracle
    - Query live data
    - Difference between NAV and market rate and why you may wish to use the one or the other
    - [ ] Foundry exercises (TODO: comments + README)
- [ ] Restake on EigenLayer
  - [ ] What is EigenLayer (TODO: excalidraw)
    - Advantages and risks of restaking
  - [ ] Foundry exercises (TODO: comments + README)
- [ ] L2 tokens

### Notes

- RETH
  - RocketDepositPool
    - RocketDAOProtocolSettingsDeposit
    - RocketVault
    - RocketMinipoolQueue
  - RocketNetworkBalances

### Changes

- 2.4 best options to obtain rETH -> explained in 2.1
- 3.1 Leverage ETH to rETH -> Leverage rETH

### Resources

- [ETH staking](https://ethereum.org/en/staking/)
- [Deposit contract](https://etherscan.io/address/0x00000000219ab540356cBB839Cbe05303d7705Fa)
- [Rocket Pool GitHub](https://github.com/rocket-pool/rocketpool)
- [Rocket Pool Contracts and integrations](https://docs.rocketpool.net/overview/contracts-integrations)
- [rETH](https://etherscan.io/address/0xae78736cd615f374d3085123a210448e74fc6393)
- [Chainlink rETH / ETH](https://data.chain.link/feeds/ethereum/mainnet/reth-eth)
- [Chainlink addresses](https://docs.chain.link/data-feeds#price-feeds)
- [RocketDepositPool](https://etherscan.io/address/0xDD3f50F8A6CafbE9b31a427582963f465E745AF8)
- [RocketNetworkBalances](https://etherscan.io/address/0x6Cc65bF618F55ce2433f9D8d827Fc44117D81399)
- [RocketDAOProtocolSettingsDeposit](https://etherscan.io/address/0xD846AA34caEf083DC4797d75096F60b6E08B7418)
- [Aave error codes](https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/libraries/helpers/Errors.sol)
- [Balancer](https://balancer.fi/)
- [Balancer docs](https://docs.balancer.fi/)
- [Balancer V2 GitHub](https://github.com/balancer/balancer-v2-monorepo)
- [Balancer V2 rETH/WETH pool](https://balancer.fi/pools/ethereum/v2/0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112)
- [Aura](https://aura.finance/)
- [Aura GitHub](https://github.com/aurafinance/aura-contracts)
- [Aura GitHub convex fork](https://github.com/aurafinance/convex-platform)
- [Balancer - Aura Ceazor'sSnack Sandwich](https://www.youtube.com/watch?v=1VQ3hdnn3yc)
- [Curve](https://curve.fi/)
- [Eigenlayer](https://www.eigenlayer.xyz/)
- [Eigenlayer GitHub](https://github.com/Layr-Labs/eigenlayer-contracts)
- [Eigenlayer flow](https://github.com/Layr-Labs/eigenlayer-contracts/tree/dev/docs#common-user-flows)
- [Eigenlayer testnet](https://holesky.eigenlayer.xyz/)
- [Aave flash leverage open position tx](https://etherscan.io/tx/0x79c5fb4ab1b5fc87842643410aa058c8b634650d5da16eb24728cc6ef793554b)
- [Aave flash leverage close position tx (profit 2.5813 DAI)](https://etherscan.io/tx/0x03778694892ac46b37269e9ea0f64bd100326faa3abbb2b235a6dd3d15c3d240)
