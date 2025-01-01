// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IRocketDepositPool} from
    "../interfaces/rocket-pool/IRocketDepositPool.sol";
import {IRocketDAOProtocolSettingsDeposit} from
    "../interfaces/rocket-pool/IRocketDAOProtocolSettingsDeposit.sol";
import {IRocketStorage} from "../interfaces/rocket-pool/IRocketStorage.sol";
import {
    RETH,
    ROCKET_STORAGE,
    ROCKET_DEPOSIT_POOL,
    ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT
} from "../Constants.sol";

contract SwapRocketPool {
    IRETH public constant reth = IRETH(RETH);
    IRocketStorage public constant rStorage = IRocketStorage(ROCKET_STORAGE);
    IRocketDepositPool public constant depositPool =
        IRocketDepositPool(ROCKET_DEPOSIT_POOL);
    IRocketDAOProtocolSettingsDeposit public constant protocolSettings =
        IRocketDAOProtocolSettingsDeposit(ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT);

    uint256 constant CALC_BASE = 1e18;

    function calcEthToReth(uint256 ethAmount)
        external
        view
        returns (uint256 rEthAmount, uint256 fee)
    {
        // Write your code here
    }

    function calcRethToEth(uint256 rEthAmount)
        external
        view
        returns (uint256 ethAmount)
    {
        // Write your code here
    }

    function getAvailability() external view returns (bool, uint256) {
        // Write your code here
    }

    function getDepositDelay() public view returns (uint256) {
        // Write your code here
    }

    function getLastDepositBlock(address user) public view returns (uint256) {
        // Write your code here
    }

    function swapEthToReth() external payable {
        // Write your code here
    }

    function swapRethToEth(uint256 rEthAmount) external {
        // Write your code here
    }
}
