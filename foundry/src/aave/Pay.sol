// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Pay {
    function pay(address to, uint256 amount) external {
        require(to != address(0), "to = 0 addr");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "pay failed");
    }
}
