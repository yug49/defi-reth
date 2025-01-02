// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ISwapRouter} from "../interfaces/uniswap/ISwapRouter.sol";
import {
    RETH,
    WETH,
    UNISWAP_V3_SWAP_ROUTER_02,
    UNISWAP_V3_POOL_FEE_RETH_WETH
} from "../Constants.sol";

contract SwapUniswapV3 {
    IRETH constant reth = IRETH(RETH);
    IERC20 constant weth = IERC20(WETH);
    ISwapRouter constant router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);

    function swap(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMin,
        address receiver
    ) private returns (uint256 amountOut) {
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

    function swapWethToReth(uint256 wethAmountIn, uint256 rEthAmountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), wethAmountIn);
        weth.approve(address(router), wethAmountIn);
        swap(
            WETH,
            RETH,
            UNISWAP_V3_POOL_FEE_RETH_WETH,
            wethAmountIn,
            rEthAmountOutMin,
            address(this)
        );
    }

    function swapRethToWeth(uint256 rEthAmountIn, uint256 wethAmountOutMin)
        external
    {
        reth.transferFrom(msg.sender, address(this), rEthAmountIn);
        reth.approve(address(router), rEthAmountIn);
        swap(
            RETH,
            WETH,
            UNISWAP_V3_POOL_FEE_RETH_WETH,
            rEthAmountIn,
            wethAmountOutMin,
            address(this)
        );
    }
}
