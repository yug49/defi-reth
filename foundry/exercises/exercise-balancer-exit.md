# `BalancerLiquidity.exit` exercise

Write your code inside the [`BalancerLiquidity` contract](../src/exercises/BalancerLiquidity.sol)

This exercise is design for you to gain experience removing liquidity from Balancer.

```solidity
function exit(uint256 bptAmount, uint256 minRethAmountOut) external {
  // Write your code here
}
```

## Instructions

1. **Transfer BPT from msg.sender**

   - Transfer LP token (BPT) from `msg.sender`

2. **Remove liquidity**

   - Call internal function `_exit` to add liquidity.
   - Prepare parameters `assets` and `maxAmountsIn`. Token addresses and max amounts in must be ordered as rETH and then WETH.
   - Set receiver of tokens (rETH and WETH) to `msg.sender`.

3. **Refund**

   - Send any left over rETH and WETH in this contract to `msg.sender`.

## Testing

```shell
forge test --fork-url $FORK_URL --match-path test/exercise-balancer.sol --match-test test_exit -vvv
```
