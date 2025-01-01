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

// TODO: comments
contract BalancerLiquidity {
    IRETH private constant reth = IRETH(RETH);
    IERC20 private constant weth = IERC20(WETH);
    IVault private constant vault = IVault(BALANCER_VAULT);
    // Balancer Pool Token
    IERC20 private constant bpt = IERC20(BALANCER_POOL_RETH_WETH);

    function join(uint256 rethAmount, uint256 wethAmount) external {
        if (rethAmount > 0) {
            reth.transferFrom(msg.sender, address(this), rethAmount);
            reth.approve(address(vault), rethAmount);
        }
        if (wethAmount > 0) {
            weth.transferFrom(msg.sender, address(this), rethAmount);
            weth.approve(address(vault), rethAmount);
        }

        // Tokens must be ordered numerically by token address
        address[] memory assets = new address[](2);
        assets[0] = RETH;
        assets[1] = WETH;

        // Single sided or both liquidity is possible
        uint256[] memory maxAmountsIn = new uint256[](2);
        maxAmountsIn[0] = rethAmount;
        maxAmountsIn[1] = wethAmount;

        vault.joinPool({
            poolId: BALANCER_POOL_ID_RETH_WETH,
            sender: address(this),
            recipient: msg.sender,
            request: IVault.JoinPoolRequest({
                assets: assets,
                maxAmountsIn: maxAmountsIn,
                // EXACT_TOKENS_IN_FOR_BPT_OUT, amounts, min BPT
                userData: abi.encode(
                    IVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
                    maxAmountsIn,
                    uint256(1)
                ),
                fromInternalBalance: false
            })
        });

        uint256 rethBal = reth.balanceOf(address(this));
        if (rethBal > 0) {
            reth.transfer(msg.sender, rethBal);
        }

        uint256 wethBal = weth.balanceOf(address(this));
        if (wethBal > 0) {
            weth.transfer(msg.sender, wethBal);
        }
    }

    function exit(uint256 bptAmount, uint256 minRethAmountOut) external {
        bpt.transferFrom(msg.sender, address(this), bptAmount);

        // Tokens must be ordered numerically by token address
        address[] memory assets = new address[](2);
        assets[0] = RETH;
        assets[1] = WETH;

        // Both single and all tokens are possible
        uint256[] memory minAmountsOut = new uint256[](2);
        minAmountsOut[0] = minRethAmountOut;
        minAmountsOut[1] = 0;

        vault.exitPool({
            poolId: BALANCER_POOL_ID_RETH_WETH,
            sender: address(this),
            recipient: msg.sender,
            request: IVault.ExitPoolRequest({
                assets: assets,
                minAmountsOut: minAmountsOut,
                // EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, BPT amount, index of token to withdraw
                userData: abi.encode(
                    IVault.ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
                    bptAmount,
                    uint256(0)
                ),
                toInternalBalance: false
            })
        });
    }
}
