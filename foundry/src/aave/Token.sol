// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";

contract Token {
    function approve(address token, address spender, uint256 amount) external {
        IERC20(token).approve(spender, amount);
    }

    function transfer(address token, address dst, uint256 amount) external {
        require(dst != address(0), "dst = 0 addr");
        IERC20(token).transfer(dst, amount);
    }
}
