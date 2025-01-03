// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {Pay} from "../aave/Pay.sol";
import {Token} from "../aave/Token.sol";
import {AaveHelper} from "../aave/AaveHelper.sol";
import {SwapHelper} from "../aave/SwapHelper.sol";

// TODO: remove solution
contract FlashLev is Pay, Token, AaveHelper, SwapHelper {
    /*
    HF = health factor
    LTV = ratio of loan to value of collateral

    Open a position
    ---------------
    1. Flash loan stable coin
    2. Swap stable coin to collateral <--- makes HF < target HF
    2. Supply swapped collateral + base collateral
    3. Borrow stable coin (flash loan amount + fee)
    4. Repay flash loan

    Close a position
    ----------------
    1. Flash loan stable coin
    2. Repay stable coin debt (open step 3)
    3. Withdraw collateral (open step 2)
    4. Swap collateral to stable coin
    5. Repay flash loan

    Math - flash loan amount
    ------------------------
    total_borrow_usd / total_col_usd <= LTV

    total_borrow_usd = flash_loan_usd
                     = base_col_usd * L

    Assume swap_col_usd = flash_loan_usd (no slippage or fee on swap)

    total_col_usd = swap_col_usd + base_col_usd
                  = flash_loan_usd + base_col_usd
                  = base_col_usd * (L + 1)


    base_col_usd * L / (base_col_usd * (L + 1)) <= LTV
    L / (L + 1) <= LTV

    L <= LTV * (L + 1)
    L * (1 - LTV) <= LTV
    L <= LTV / (1 - LTV)

    flash_loan_usd = base_col_usd * L <= base_col_usd * LTV / (1 - LTV)
    */
    struct SwapParams {
        uint256 amountOutMin;
        bytes data;
    }

    struct FlashLoanData {
        address coin;
        address collateral;
        bool open;
        address caller;
        // open - initial collateral amount deposited
        // close - collateral to keep
        uint256 colAmount;
        SwapParams swap;
    }

    struct OpenParams {
        address coin;
        address collateral;
        // Collateral to deposit
        uint256 colAmount;
        uint256 coinAmount;
        SwapParams swap;
        uint256 minHealthFactor;
    }

    struct CloseParams {
        address coin;
        address collateral;
        // Collateral to keep
        uint256 colAmount;
        SwapParams swap;
    }

    function open(OpenParams calldata params) external {
        IERC20(params.collateral).transferFrom(
            msg.sender, address(this), params.colAmount
        );

        flashLoan({
            token: params.coin,
            amount: params.coinAmount,
            data: abi.encode(
                FlashLoanData({
                    coin: params.coin,
                    collateral: params.collateral,
                    open: true,
                    caller: msg.sender,
                    colAmount: params.colAmount,
                    swap: params.swap
                })
            )
        });
        require(
            getHealthFactor(address(this)) >= params.minHealthFactor, "hf < min"
        );
    }

    function close(CloseParams calldata params) external {
        uint256 coinAmount = getDebt(address(this), params.coin);
        flashLoan({
            token: params.coin,
            amount: coinAmount,
            data: abi.encode(
                FlashLoanData({
                    coin: params.coin,
                    collateral: params.collateral,
                    open: false,
                    caller: msg.sender,
                    colAmount: params.colAmount,
                    swap: params.swap
                })
            )
        });
    }

    function _flashLoanCallback(
        address token,
        uint256 amount,
        uint256 fee,
        bytes memory params
    ) internal override {
        uint256 repayAmount = amount + fee;

        FlashLoanData memory data = abi.decode(params, (FlashLoanData));
        IERC20 coin = IERC20(data.coin);
        IERC20 collateral = IERC20(data.collateral);

        if (data.open) {
            uint256 colAmountOut = swap({
                tokenIn: address(coin),
                tokenOut: address(collateral),
                amountIn: amount,
                amountOutMin: data.swap.amountOutMin,
                data: data.swap.data
            });

            uint256 colAmount = colAmountOut + data.colAmount;

            collateral.approve(address(pool), colAmount);
            supply(address(collateral), colAmount);

            borrow(address(coin), repayAmount);
        } else {
            coin.approve(address(pool), amount);
            repay(address(coin), amount);

            uint256 colWithdrawn =
                withdraw(address(collateral), type(uint256).max);
            uint256 colAmountIn = colWithdrawn - data.colAmount;

            collateral.transfer(data.caller, data.colAmount);

            uint256 coinAmountOut = swap({
                tokenIn: address(collateral),
                tokenOut: address(coin),
                amountIn: colAmountIn,
                amountOutMin: data.swap.amountOutMin,
                data: data.swap.data
            });

            if (coinAmountOut < repayAmount) {
                coin.transferFrom(
                    data.caller, address(this), repayAmount - coinAmountOut
                );
            } else {
                coin.transfer(data.caller, coinAmountOut - repayAmount);
            }
        }

        coin.approve(address(pool), repayAmount);
    }

    function getMaxFlashLoanAmountUsd(address collateral, uint256 baseColAmount)
        public
        view
        returns (uint256 max, uint256 price, uint256 ltv, uint256 maxLev)
    {
        uint256 decimals;
        (decimals, ltv,,,,,,,,) =
            dataProvider.getReserveConfigurationData(collateral);

        // 1e8 = 1 USD
        price = oracle.getAssetPrice(collateral);

        // Normalize baseColAmount to 18 decimals
        // LTV 100% = 1e4
        max = baseColAmount * 10 ** (18 - decimals) * price * ltv / (1e4 - ltv)
            / 1e8;

        maxLev = ltv * 1e4 / (1e4 - ltv);

        return (max, price, ltv, maxLev);
    }
}
