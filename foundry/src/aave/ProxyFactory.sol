// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Proxy} from "./Proxy.sol";

contract ProxyFactory {
    event Deploy(address indexed owner, address proxy);

    function deploy() external returns (address proxy) {
        proxy = address(new Proxy(msg.sender));
        emit Deploy(msg.sender, proxy);
    }
}
