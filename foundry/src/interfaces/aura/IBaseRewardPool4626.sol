// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IBaseRewardPool4626 {
    function balanceOf(address) external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function deposit(uint256 amount, address receiver)
        external
        returns (uint256);
    function getReward() external;
    function withdrawAndUnwrap(uint256 amount, bool claim)
        external
        returns (bool);
}
