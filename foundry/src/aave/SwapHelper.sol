// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {IVault} from "../interfaces/balancer/IVault.sol";
import {ISwapRouter} from "../interfaces/uniswap/ISwapRouter.sol";
import {
    WETH, BALANCER_VAULT, UNISWAP_V3_SWAP_ROUTER_02
} from "../Constants.sol";

// TODO: comments
abstract contract SwapHelper {
    IERC20 internal constant weth = IERC20(WETH);
    IVault internal constant vault = IVault(BALANCER_VAULT);
    ISwapRouter internal constant router =
        ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);

    function swapUniV3(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMin,
        address receiver
    ) internal returns (uint256 amountOut) {
        return router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: receiver,
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            })
        );
    }

    function swapBalancerV2(
        address tokenIn,
        address tokenOut,
        bytes32 poolId,
        uint256 amountIn,
        uint256 amountOutMin,
        address receiver
    ) internal returns (uint256 amountOut) {
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
                recipient: receiver,
                toInternalBalance: false
            }),
            limit: amountOutMin,
            deadline: block.timestamp
        });
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes memory data
    ) internal returns (uint256 amountOut) {
        (bool open, uint24 uniV3PoolFee, bytes32 balPoolId) =
            abi.decode(data, (bool, uint24, bytes32));

        // DAI (coin) <-- Uniswap --> WETH <-- Balancer --> RETH (collateral)
        // open =  DAI -> RETH
        // close = DAI <- RETH
        if (open) {
            IERC20(tokenIn).approve(address(router), amountIn);

            uint256 wethAmountOut = swapUniV3({
                tokenIn: tokenIn,
                tokenOut: WETH,
                fee: uniV3PoolFee,
                amountIn: amountIn,
                amountOutMin: 1,
                receiver: address(this)
            });

            weth.approve(address(vault), wethAmountOut);

            return swapBalancerV2({
                tokenIn: WETH,
                tokenOut: tokenOut,
                poolId: balPoolId,
                amountIn: wethAmountOut,
                amountOutMin: amountOutMin,
                receiver: address(this)
            });
        } else {
            IERC20(tokenIn).approve(address(vault), amountIn);

            uint256 wethAmountOut = swapBalancerV2({
                tokenIn: tokenIn,
                tokenOut: WETH,
                poolId: balPoolId,
                amountIn: amountIn,
                amountOutMin: 1,
                receiver: address(this)
            });

            weth.approve(address(router), wethAmountOut);

            return swapUniV3({
                tokenIn: address(weth),
                tokenOut: tokenOut,
                fee: uniV3PoolFee,
                amountIn: wethAmountOut,
                amountOutMin: amountOutMin,
                receiver: address(this)
            });
        }
    }
}
