// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IVault} from "../interfaces/balancer/IVault.sol";
import {
    RETH,
    WETH,
    BALANCER_VAULT,
    BALANCER_POOL_ID_RETH_WETH
} from "../Constants.sol";

contract SwapBalancerV2 {
    IRETH constant reth = IRETH(RETH);
    IERC20 constant weth = IERC20(WETH);
    IVault constant vault = IVault(BALANCER_VAULT);

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes32 poolId
    ) private returns (uint256 amountOut) {
        return vault.swap({
            singleSwap: IVault.SingleSwap({
                poolId: poolId,
                kind: IVault.SwapKind.GIVEN_IN,
                assetIn: tokenIn,
                assetOut: tokenOut,
                amount: amountIn,
                userData: ""
            }),
            funds: IVault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: address(this),
                toInternalBalance: false
            }),
            limit: amountOutMin,
            deadline: block.timestamp
        });
    }

    function swapWethToReth(uint256 wethAmountIn, uint256 rEthAmountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), wethAmountIn);
        weth.approve(address(vault), wethAmountIn);
        swap(
            WETH,
            RETH,
            wethAmountIn,
            rEthAmountOutMin,
            BALANCER_POOL_ID_RETH_WETH
        );
    }

    function swapRethToWeth(uint256 rEthAmountIn, uint256 wethAmountOutMin)
        external
    {
        reth.transferFrom(msg.sender, address(this), rEthAmountIn);
        reth.approve(address(vault), rEthAmountIn);
        swap(
            RETH,
            WETH,
            rEthAmountIn,
            wethAmountOutMin,
            BALANCER_POOL_ID_RETH_WETH
        );
    }
}
