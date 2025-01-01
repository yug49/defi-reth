// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {IVault} from "../balancer/IVault.sol";

interface IRewardPoolDepositWrapper {
    function depositSingle(
        address rewardPool,
        address inputToken,
        uint256 inputAmount,
        bytes32 balancerPoolId,
        IVault.JoinPoolRequest memory request
    ) external;
}
