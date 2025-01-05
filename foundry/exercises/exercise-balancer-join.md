# `BalancerLiquidity.join` exercise

Write your code inside the [`BalancerLiquidity` contract](../src/exercises/BalancerLiquidity.sol)

This exercise is design for you to gain experience adding liquidity to Balancer.

```solidity
 function join(uint256 rethAmount, uint256 wethAmount) external {
     // Write your code here
 }
```

## Instructions

1. **Calculate the ETH to rETH exchange rate**

   - Implement logic to compute the amount of rETH given `ethAmount`. `rEthAmount` must include the deposit fee.

   > **Hint:** Check the Rocket Pool contracts (`RocketDepositPool` and `RocketTokenRETH`) for how to fetch
   > data that are needed to calculate the exchange rate.

## Testing

```shell
forge test --fork-url $FORK_URL --match-path test/exercise-swap-rocket-pool.sol --match-test test_calcEthToReth -vvv
```
