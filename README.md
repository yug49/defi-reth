# rETH Integration

### Foundry

```shell
cd foundry
forge build
```

### 1 - Introduction

- [ ] Overview
- [ ] Objectives
  - [ ] What is the course about
  - [ ] Who is it for?
  - [ ] What will you learn?
- [ ] Prerequisites
- [ ] Project setup
  - forge setup
  - fork url

### 2 - Understanding rETH

- [x] 2.1 - What is rETH
  - [x] [ETH staking](./notes/eth-stake.png)
  - [x] [What problem does Rocket Pool solve?](./notes/rocket-pool.png)
  - [x] [What is rETH?](./notes/reth.png)
  - [x] [Value of rETH](./notes/reth.png)
  - [x] What can you do with rETH?
    - Examples - Uniswap V3, Curve, Balancer, Aura, Aave V3, EigenLayer
  - [x] How to obtain rETH and redeem ETH
    - browser - Rocket pool, Uniswap, Curve V2, DEX aggregator
- [x] [rETH contract overview](./notes/reth-flow.png)
- [x] 2.3 - Exchange rates
  - [x] How exchange rate is calculated
    - [x] [Math](./notes/reth-exchange-rate.png)
    - [x] Comments on code
      - [`RocketDepositPool.deposit`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/deposit/RocketDepositPool.sol#L90-L127)
      - [`RocketTokenRETH.mint`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/token/RocketTokenRETH.sol#L94-L103)
      - [`RocketTokenRETH.burn`](https://github.com/rocket-pool/rocketpool/blob/fb53ec9ee9546faea70799ac8903005300eec9d6/contracts/contract/token/RocketTokenRETH.sol#L106-L123)
    - [x] Foundry exercises
      - [x] [Calculate exchange rate from ETH to rETH](./foundry/exercises/exercise-calc-ex-rate-eth-reth.md)
      - [x] [Calculate exchange rate from rETH to ETH](./foundry/exercises/exercise-calc-ex-rate-reth-eth.md)
- [x] Availability and deposit delay
  - [x] Foundry exercises
    - [x] [Get availability](./foundry/exercises/exercise-get-avail.md)
    - [x] [Get deposit delay](./foundry/exercises/exercise-get-deposit-delay.md)
    - [x] [Get last user deposit block](./foundry/exercises/exercise-get-last-user-deposit-block.md)
- [x] 2.4 - Swapping between ETH and rETH
  - [x] Foundry exercises
    - [x] [Rocket Pool (ETH to rETH)](./foundry/exercises/exercise-swap-rocket-pool-eth-reth.md)
    - [x] [Rocket Pool (rETH to ETH)](./foundry/exercises/exercise-swap-rocket-pool-reth-eth.md)
    - [x] [Uniswap V3 (WETH to rETH)](./foundry/exercises/exercise-swap-uni-v3-weth-reth.md)
    - [x] [Uniswap V3 (rETH to WETH)](./foundry/exercises/exercise-swap-uni-v3-reth-weth.md)
    - [x] [Balancer V2 (WETH to rETH)](./foundry/exercises/exercise-swap-balancer-v2-weth-reth.md)
    - [x] [Balancer V2 (rETH to WETH)](./foundry/exercises/exercise-swap-balancer-v2-reth-weth.md)
    - [x] Curve (skip)

### 3 - DeFi integrations

- [ ] Leverage rETH
  - [x] What we are building
  - [x] [What is AAVE](./notes/aave.png)
    - Overcollateralized loan
    - LTV
    - health factor
  - [x] [What is leverage](./notes/leverage.png)
    - Example
  - [x] [Math](./notes/max-leverage.png)
  - [x] [Flash leverage flow](./notes/flash-lev.png)
  - [x] [Flash leverage math](./notes/flash-lev.png)
  - [x] [Application design](./notes/flash-lev-design.png)
    - Limitations (one position / proxy)
  - [x] Foundry exercises
    - [Get max flash loan amount](./foundry/exercises/exercise-aave-flash-lev-get-max-loan.md)
    - [Open a leveraged position](./foundry/exercises/exercise-aave-flash-lev-open.md)
    - [Close a leveraged position](./foundry/exercises/exercise-aave-flash-lev-close.md)
  - [ ] Scripts (TODO: markdown file)
    - How to setup and execute scripts
    - Tx examples
      - [Proxy](https://etherscan.io/address/0xC5aCD8c4604476FEFfd4bEb164a22f70ed56884D)
      - [FlashLev](https://etherscan.io/address/0xDcc6Dc8D59626E4E851c6b76df178Ab0C390bAF8)
      - [Aave flash leverage open position tx](https://etherscan.io/tx/0x79c5fb4ab1b5fc87842643410aa058c8b634650d5da16eb24728cc6ef793554b)
      - [Aave flash leverage close position tx (profit 2.5813 DAI)](https://etherscan.io/tx/0x03778694892ac46b37269e9ea0f64bd100326faa3abbb2b235a6dd3d15c3d240)
- [x] Provide liquidity to Balancer / Aura
  - [x] [What is Balancer](./notes/balancer-v2.png)
  - [x] [What is Aura](./notes/balancer-v2.png)
  - [x] Balancer UI walkthrough
    - [Add liquidity](https://etherscan.io/tx/0x8cce73567eef34d20c435a336ed0bbc667ca5937a3d7c7d876f0f9cf89766a80)
    - [Stake LP to Liquidity Gauge](https://etherscan.io/tx/0x507b35b84d1685a7c6e5a79f0f17024096e4f042b246047932a28b2de4d03c14)
    - [Add BAL/WETH liquidity](https://etherscan.io/tx/0x0612d067b5220750569b901400b3f2624ed0e5488ffeba3ae5e62a86e65bb99f)
    - [Lock BAL/WETH LP](https://etherscan.io/tx/0x1fd35f3b2d2fc146f087af52a90013784aa20fddde00b95ec82c2a7d19e9ba61)
    - [Vote for rewards to rETH/WETH pool](https://etherscan.io/tx/0x0c523f52cedb207d93ef0db682c84dc0c601444480497ae13df832abccaee89b)
    - [Claim rewards](https://etherscan.io/tx/0x52c10c465eb39ca9bace336eb1c95cda3bc8df5767c6e56aaaaf98143131029e)
  - [x] Aura UI walkthrough
    - [Deposit rETH](https://etherscan.io/tx/0xb93f1c4ed66b7a92661c2350e95553811008618ec5921867977e37aca8e3ba09)
    - [Claim rewards](https://etherscan.io/tx/0x6f981d560c77e30588af65e28fd6d1c604bdb3fc55f0c42d4bac01f34ec88065)
  - [x] Foundry exercises
    - [x] [Balancer add liquidity](./foundry/exercises/exercise-balancer-join.md)
    - [x] [Balancer remove liquidity](./foundry/exercises/exercise-balancer-exit.md)
    - [x] [Aura add liquidity](./foundry/exercises/exercise-aura-deposit.md)
    - [x] [Aura get reward](./foundry/exercises/exercise-aura-get-reward.md)
    - [x] [Aura remove liquidity](./foundry/exercises/exercise-aura-exit.md)
- [x] Rocket Pool NAV oracle
  - [x] [What is NAV oracle](./notes/rocket-pool-nav.png)
    - [x] [Query live data](https://etherscan.io/address/0xae78736cd615f374d3085123a210448e74fc6393#readContract#F6)
    - [x] Foundry exercise
      - [x] [rETH NAV](./foundry/exercises/exercise-reth-nav.md)
- [ ] Restake on EigenLayer
  - [ ] [What is EigenLayer - problem](./notes/eigen-layer.png)
  - [ ] [What is EigenLayer - solution](./notes/eigen-layer.png)
    - Advantages and risks of restaking
  - [ ] [How it works](./notes/eigen-layer.png)
    - AVS
    - stakers
    - operators
    - unboding period
  - [ ] [Contract architecture](./notes/eigen-layer-arc.png)
  - [ ] [Reward Merkle tree diagram](./notes/eigen-layer-reward-merkle.png)
  - [ ] Transactions
    - [Deposit rETH](https://etherscan.io/tx/0xfb709b9a4b33371970e4fb3bcd3aefe8f20a97a373336feef5e42d49282d91c2)
    - [Delegate](https://etherscan.io/tx/0xda7b7122bcb9c9d0f7cd111683a85ecb3c514ab5f14f1d412ad102804d02fe94)
    - [Claim rewards](https://etherscan.io/tx/0x29226a1cb445faa3e1e7850f4f669a9e028e21c30f1c50137fdd2885ddd30df6)
    - [Queue withdraw of rETH](https://etherscan.io/tx/0xc4e7a7c6556fb40dbeada645634cea8c8c7bb47b8f5e04858d8f4cd2d04bf02a)
    - [Withdraw rETH](https://etherscan.io/tx/0x743a95867d308ae24332cd34c73762d14254b3aa7d2239aee1266ea65e810bf7)
  - [ ] Foundry exercises
    - [ ] [Deposit](./foundry/exercises/exercise-eigen-layer-deposit.md)
    - [ ] [Delegate](./foundry/exercises/exercise-eigen-layer-delegate.md)
    - [ ] [Undelegate](./foundry/exercises/exercise-eigen-layer-undelegate.md)
    - [ ] [Withdraw](./foundry/exercises/exercise-eigen-layer-withdraw.md)
- [ ] L2 tokens

- TODO: Geometric series
- TODO: Note on arbitrage (Uniswap V3 ETH -> rETH -> RocketPool burn rETH -> ETH)

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

##### ETH Staking

- [ETH staking](https://ethereum.org/en/staking/)
- [Deposit contract](https://etherscan.io/address/0x00000000219ab540356cBB839Cbe05303d7705Fa)

##### Rocket Pool

- [Rocket Pool GitHub](https://github.com/rocket-pool/rocketpool)
- [Rocket Pool Contracts and integrations](https://docs.rocketpool.net/overview/contracts-integrations)
- [rETH](https://etherscan.io/address/0xae78736cd615f374d3085123a210448e74fc6393)
- [Chainlink rETH / ETH](https://data.chain.link/feeds/ethereum/mainnet/reth-eth)
- [Chainlink addresses](https://docs.chain.link/data-feeds#price-feeds)
- [RocketDepositPool](https://etherscan.io/address/0xDD3f50F8A6CafbE9b31a427582963f465E745AF8)
- [RocketNetworkBalances](https://etherscan.io/address/0x6Cc65bF618F55ce2433f9D8d827Fc44117D81399)
- [RocketDAOProtocolSettingsDeposit](https://etherscan.io/address/0xD846AA34caEf083DC4797d75096F60b6E08B7418)

##### Aave

- [Aave error codes](https://github.com/aave/aave-v3-core/blob/master/contracts/protocol/libraries/helpers/Errors.sol)

##### Aave Flash Leverage

- [Proxy](https://etherscan.io/address/0xC5aCD8c4604476FEFfd4bEb164a22f70ed56884D)
- [FlashLev](https://etherscan.io/address/0xDcc6Dc8D59626E4E851c6b76df178Ab0C390bAF8)
- [Aave flash leverage open position tx](https://etherscan.io/tx/0x79c5fb4ab1b5fc87842643410aa058c8b634650d5da16eb24728cc6ef793554b)
- [Aave flash leverage close position tx (profit 2.5813 DAI)](https://etherscan.io/tx/0x03778694892ac46b37269e9ea0f64bd100326faa3abbb2b235a6dd3d15c3d240)

##### Balancer

- [Balancer](https://balancer.fi/)
- [Balancer docs](https://docs.balancer.fi/)
- [Balancer V2 GitHub](https://github.com/balancer/balancer-v2-monorepo)
- [Balancer V2 rETH/WETH pool](https://balancer.fi/pools/ethereum/v2/0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112)

##### Aura

- [Aura](https://aura.finance/)
- [Aura GitHub](https://github.com/aurafinance/aura-contracts)
- [Aura GitHub convex fork](https://github.com/aurafinance/convex-platform)
- [Balancer - Aura Ceazor'sSnack Sandwich](https://www.youtube.com/watch?v=1VQ3hdnn3yc)

##### Curve

- [Curve](https://curve.fi/)

##### EigenLayer

- [Eigenlayer](https://www.eigenlayer.xyz/)
- [Eigenlayer GitHub](https://github.com/Layr-Labs/eigenlayer-contracts)
- [Eigenlayer flow](https://github.com/Layr-Labs/eigenlayer-contracts/tree/dev/docs#common-user-flows)
- [Eigenlayer testnet](https://holesky.eigenlayer.xyz/)
- [You Could've Invented EigenLayer](https://www.blog.eigenlayer.xyz/ycie/)
- [EigenLayer Explained: What is Restaking?](https://www.youtube.com/watch?v=5r0SooSQFJg)
