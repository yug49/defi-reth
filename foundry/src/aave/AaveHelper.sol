// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {IPool} from "../interfaces/aave/IPool.sol";
import {IAaveOracle} from "../interfaces/aave/IAaveOracle.sol";
import {IPoolDataProvider} from "../interfaces/aave/IPoolDataProvider.sol";
import {
    AAVE_POOL, AAVE_ORACLE, AAVE_POOL_DATA_PROVIDER
} from "../Constants.sol";

// TODO: comments
abstract contract AaveHelper {
    IPool internal constant pool = IPool(AAVE_POOL);
    IPoolDataProvider internal constant dataProvider =
        IPoolDataProvider(AAVE_POOL_DATA_PROVIDER);
    IAaveOracle internal constant oracle = IAaveOracle(AAVE_ORACLE);

    function supply(address token, uint256 amount) public {
        pool.supply({
            asset: token,
            amount: amount,
            onBehalfOf: address(this),
            referralCode: 0
        });
    }

    function borrow(address token, uint256 amount) public {
        pool.borrow({
            asset: token,
            amount: amount,
            // Variable rate
            interestRateMode: 2,
            referralCode: 0,
            onBehalfOf: address(this)
        });
    }

    // amount = type(uint256).max to repay all
    function repay(address token, uint256 amount)
        public
        returns (uint256 repaid)
    {
        return pool.repay({
            asset: token,
            amount: amount,
            // Variable rate
            interestRateMode: 2,
            onBehalfOf: address(this)
        });
    }

    // amount = type(uint256).max to withdraw all
    function withdraw(address token, uint256 amount)
        public
        returns (uint256 withdrawn)
    {
        return pool.withdraw({asset: token, amount: amount, to: address(this)});
    }

    function flashLoan(address token, uint256 amount, bytes memory data)
        public
    {
        pool.flashLoanSimple({
            receiverAddress: address(this),
            asset: token,
            amount: amount,
            params: data,
            referralCode: 0
        });
    }

    function executeOperation(
        address token,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        require(msg.sender == address(pool), "not authorized");
        require(initiator == address(this), "invalid initiator");

        _flashLoanCallback(token, amount, fee, params);

        return true;
    }

    function _flashLoanCallback(
        address token,
        uint256 amount,
        uint256 fee,
        bytes memory params
    ) internal virtual;

    function getDebt(address user, address token)
        public
        view
        returns (uint256)
    {
        IPool.ReserveData memory reserve = pool.getReserveData(token);
        return IERC20(reserve.variableDebtTokenAddress).balanceOf(user);
    }

    function getHealthFactor(address user) public view returns (uint256) {
        (
            , // uint256 totalCollateralBase
            , // uint256 totalDebtBase
            , // uint256 availableBorrowsBase
            , // uint256 currentLiquidationThreshold
            , // uint256 ltv
            uint256 healthFactor
        ) = pool.getUserAccountData(user);

        return healthFactor;
    }
}
