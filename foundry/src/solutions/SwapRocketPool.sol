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
    IRETH constant reth = IRETH(RETH);
    IRocketStorage constant rStorage = IRocketStorage(ROCKET_STORAGE);
    IRocketDepositPool constant depositPool =
        IRocketDepositPool(ROCKET_DEPOSIT_POOL);
    IRocketDAOProtocolSettingsDeposit constant protocolSettings =
        IRocketDAOProtocolSettingsDeposit(ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT);

    uint256 constant CALC_BASE = 1e18;

    // Receive ETH from RocketPool
    receive() external payable {}

    function calcEthToReth(uint256 ethAmount)
        external
        view
        returns (uint256 rEthAmount, uint256 fee)
    {
        uint256 depositFee = protocolSettings.getDepositFee();
        fee = ethAmount * depositFee / CALC_BASE;
        ethAmount -= fee;
        rEthAmount = reth.getRethValue(ethAmount);
    }

    function calcRethToEth(uint256 rEthAmount)
        external
        view
        returns (uint256 ethAmount)
    {
        ethAmount = reth.getEthValue(rEthAmount);
    }

    function getAvailability() external view returns (bool, uint256) {
        return (
            protocolSettings.getDepositEnabled(),
            depositPool.getMaximumDepositAmount()
        );
    }

    function getDepositDelay() external view returns (uint256) {
        return rStorage.getUint(
            keccak256(
                abi.encodePacked(
                    keccak256("dao.protocol.setting.network"),
                    "network.reth.deposit.delay"
                )
            )
        );
    }

    function getLastDepositBlock(address user)
        external
        view
        returns (uint256)
    {
        return rStorage.getUint(
            keccak256(abi.encodePacked("user.deposit.block", user))
        );
    }

    function swapEthToReth() external payable {
        depositPool.deposit{value: msg.value}();
    }

    function swapRethToEth(uint256 rEthAmount) external {
        reth.transferFrom(msg.sender, address(this), rEthAmount);
        reth.burn(rEthAmount);
    }
}
