// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IVault} from "../interfaces/balancer/IVault.sol";
import {
    WETH,
    RETH,
    BALANCER_VAULT,
    BALANCER_POOL_RETH_WETH,
    BALANCER_POOL_ID_RETH_WETH
} from "../Constants.sol";

/// @title BalancerLiquidity
/// @notice This contract allows users to join or exit the Balancer RETH/WETH liquidity pool
//          by interacting with the Balancer Vault.
/// @dev The contract facilitates both single-sided and double-sided liquidity provision
//       to the Balancer pool. Users can deposit RETH and/or WETH to earn Balancer Pool Tokens (BPT).
contract BalancerLiquidity {
    IRETH private constant reth = IRETH(RETH);
    IERC20 private constant weth = IERC20(WETH);
    IVault private constant vault = IVault(BALANCER_VAULT);
    // Balancer Pool Token
    IERC20 private constant bpt = IERC20(BALANCER_POOL_RETH_WETH);

    /// @notice Deposit RETH and/or WETH into the Balancer liquidity pool
    /// @param rethAmount The amount of RETH to deposit
    /// @param wethAmount The amount of WETH to deposit
    /// @dev This function allows the user to provide liquidity to the RETH/WETH Balancer pool.
    ///      It accepts both RETH and WETH as input and approves the respective tokens for the Vault.
    ///      The user receives Balancer Pool Tokens (BPT) as a representation of their share in the pool.
    function join(uint256 rethAmount, uint256 wethAmount) external {
        // Write your code here
    }

    /// @notice Exit the Balancer liquidity pool and withdraw RETH and/or WETH
    /// @param bptAmount The amount of Balancer Pool Tokens (BPT) to redeem
    /// @param minRethAmountOut The minimum amount of RETH to receive from the exit
    /// @dev This function allows the user to withdraw their share of liquidity from the RETH/WETH Balancer pool.
    ///      It performs an exit from the pool and returns RETH and/or WETH.
    function exit(uint256 bptAmount, uint256 minRethAmountOut) external {
        // Write your code here
    }
}
