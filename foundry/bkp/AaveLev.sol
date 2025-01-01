
contract Lev {
    IERC20 constant reth = IERC20(RETH);
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant dai = IERC20(DAI);
    IPool constant pool = IPool(AAVE_POOL);
    IAaveOracle constant oracle = IAaveOracle(AAVE_ORACLE);
    IERC20 constant debtToken = IERC20(AAVE_VAR_DEBT_DAI);
    IVault vault = IVault(BALANCER_VAULT);
    ISwapRouter constant router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);
    uint24 constant UNI_V3_POOL_FEE_DAI_ETH = 3000;
    // max 100
    uint256 constant BORROW_RATIO = 70;
    uint256 constant MAX_BORROW_RATIO = 100;

    function approve(address token, address spender, uint256 amount) private {
        IERC20(token).approve(spender, amount);
    }

    function supply(address token, uint256 amount) private {
        pool.supply({
            asset: token,
            amount: amount,
            onBehalfOf: address(this),
            referralCode: 0
        });
    }

    function borrow(address token, uint256 amount) private {
        pool.borrow({
            asset: token,
            amount: amount,
            // Variable rate
            interestRateMode: 2,
            referralCode: 0,
            onBehalfOf: address(this)
        });
    }

    function repay(address token, uint256 amount) private {
        pool.repay({
            asset: token,
            amount: amount,
            interestRateMode: 2,
            onBehalfOf: address(this)
        });
    }

    function withdraw(address token, uint256 amount)
        private
        returns (uint256)
    {
        return pool.withdraw({asset: token, amount: amount, to: address(this)});
    }

    function getMaxBorrowAmount() private view returns (uint256) {
        (,, uint256 availableToBorrowUsd,,,) =
            pool.getUserAccountData(address(this));
        uint256 amount =
            availableToBorrowUsd * 1e10 * BORROW_RATIO / MAX_BORROW_RATIO;
        return amount;
    }

    function getRepayAmount() private view returns (uint256) {
        return debtToken.balanceOf(address(this));
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin
    ) public returns (uint256) {
        // DAI <-> WETH <-> RETH
        // Balancer RETH <-> WETH
        // Uniswap WETH <-> DAI

        approve(DAI, address(router), amountIn);

        uint256 amountOut = router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: UNI_V3_POOL_FEE_DAI_ETH,
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: amountOutMin,
                sqrtPriceLimitX96: 0
            })
        );

        console.log("DAI %e -> WETH %e", amountIn, amountOut);

        return 0;

        /*
        uint256 amountOut = vault.swap({
            singleSwap: IVault.SingleSwap({
                poolId: BALANCER_RETH_WETH_POOL_ID,
                kind: IVault.SwapKind.GIVEN_IN,
                assetIn: RETH,
                assetOut: WETH,
                amount: 1e18,
                userData: ""
            }),
            funds: IVault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: address(this),
                toInternalBalance: false
            }),
            limit: 1,
            deadline: block.timestamp
        });

        return 0;
        */
    }

    // TODO: loop rETH instead of ETH?
    // TODO: leverage using flash loan?
    // Leverage
    // 1. Supply rETH
    // 2. Borrow DAI
    // 3. Buy WETH
    // ----------
    // 4. Supply WETH
    // 5. Borrow DAI
    // 6. Buy WETH
    // 7. Repeat from 4

    function up(
        address supplyToken,
        address borrowToken,
        address buyToken,
        uint256 supplyAmount
    ) private returns (uint256 boughtAmount) {
        approve(supplyToken, address(pool), supplyAmount);
        supply(supplyToken, supplyAmount);

        uint256 borrowAmount = getMaxBorrowAmount();
        borrow(borrowToken, borrowAmount);

        uint256 borrowedAmount = IERC20(borrowToken).balanceOf(address(this));
        approve(borrowToken, address(router), borrowedAmount);
        // TODO: splippage protection
        // TODO: log health factor
        return swap(borrowToken, buyToken, borrowedAmount, 1);
    }

    function loopUp() public {
        uint256 bal = reth.balanceOf(address(this));
        bal = up(RETH, DAI, WETH, bal);
        console.log("bal %e", bal);
        bal = up(WETH, DAI, WETH, bal);
        console.log("bal %e", bal);
        // bal = up(WETH, DAI, WETH, bal);
        // console.log("bal %e", bal);
        // bal = up(WETH, DAI, WETH, bal);
        // console.log("bal %e", bal);

        // approve(WETH, address(pool), bal);
        // supply(WETH, bal);
    }

    // Unwind
    // 1. Sell ETH
    // 2. Repay DAI
    // 3. Withdraw ETH
    // 4. Repeat 1
    // ----------
    // 5. Sell ETH
    // 6. Repay DAI
    // 7. Withdraw rETH
    uint256 public constant HEALTH_FACTOR_LIQUIDATION_THRESHOLD = 1e18;

    function down(
        address supplyToken,
        address borrowToken,
        address sellToken,
        uint256 sellAmount
    ) private returns (uint256 withdrawnAmount) {
        approve(sellToken, address(router), sellAmount);
        uint256 amountOut = swap(sellToken, borrowToken, sellAmount, 1);

        // TODO: calc repay amount
        uint256 repayAmount = getRepayAmount();
        console.log("repay %e %e", repayAmount, amountOut);

        approve(borrowToken, address(pool), amountOut);
        repay(borrowToken, amountOut);

        // TODO: calculate withdrawable amount
        /*

        1 <= hf
        1 <= hf = avg_liq_threshold * total_col_usd / total_borrow_usd
        1 <= hf = avg_liq_threshold * (total_col_usd - withdraw_col_usd) / total_borrow_usd

        hf * total_borrow_usd = avg_liq * (total_col_usd - withdraw_col_usd)

        withdraw_col_usd <= total_col_usd - total_borrow_usd / avg_liq_threshold

            loan_usd / ((collateral - free) * col_usd) <= ltv
            loan_usd <= ltv * (col - free) * col_usd
            free * col_usd <= ltv * col * col_usd - loan_usd

        # Flash loan math
        1 <= hf = avg_liq_threshold * total_col_usd / total_borrow_usd

        assume swap_col_usd = flash_loan_usd (no splippage or fee on swap)

        total_col_usd = swap_col_usd + base_col_usd
                      = flash_loan_usd + base_col_usd

        total_borrow_usd = flash_loan_usd
                         = base_col_usd * L

        1 <= hf = avg_liq_threshold * (flash_loan_usd + base_col_usd) / (base_col_usd * L)
                = avg_liq_threshold * base_col_usd * (L + 1) / (base_col_usd * L)
                = avg_liq_threshold * (L + 1) / L

             a = avg_liq_threshold
             L - aL <= a
             L(1 - a) <= a
             L <= a / (1 - a)

             flash_loan_usd <= base_col_usd * a / (1- a)

        */
        uint256 price = oracle.getAssetPrice(supplyToken);
        console.log("price %e", price);

        (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        ) = pool.getUserAccountData(address(this));

        console.log("col usd %e", totalCollateralBase);
        console.log("debt usd %e", totalDebtBase);
        console.log("liq %e", currentLiquidationThreshold);
        uint256 withdrawUsd = totalCollateralBase
            - totalDebtBase * 1e5 / currentLiquidationThreshold;
        console.log("withdraw USD %e", withdrawUsd);
        withdrawUsd = withdrawUsd * 1e8 / price;
        console.log("withdraw ETH %e", withdrawUsd);
        withdrawUsd = withdraw(supplyToken, withdrawUsd * 1e10);
        console.log("withdrawn %e", withdrawUsd);
    }

    function loopDown() public {
        console.log("a token %e", IERC20(AAVE_A_RETH).balanceOf(address(this)));
        console.log("debt %e", debtToken.balanceOf(address(this)));
        uint256 bal = weth.balanceOf(address(this));
        bal = down(RETH, DAI, WETH, bal);
        console.log("bal %e", bal);
        // bal = down(RETH, DAI, WETH, bal);
        // console.log("bal %e", bal);
    }
}
