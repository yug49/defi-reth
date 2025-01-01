// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IAggregatorV3} from "../interfaces/chainlink/IAggregatorV3.sol";
import {RETH, CHAINLINK_RETH_ETH} from "../Constants.sol";

// forge test --fork-url $FORK_URL --match-path test/exercise-reth-nav.sol -vv

// TODO: comments
contract RethNav {
    IRETH private constant reth = IRETH(RETH);
    IAggregatorV3 private constant agg = IAggregatorV3(CHAINLINK_RETH_ETH);

    function getExchangeRate() external view returns (uint256) {
        // Returns 18 decimals
        return reth.getExchangeRate();
    }

    function getExchangeRateFromChainlink() external view returns (uint256) {
        (
            , // uint80 roundId,
            // Returns 18 decimals
            int256 rate,
            , // uint256 startedAt,
            uint256 updatedAt,
            // uint80 answeredInRound
        ) = agg.latestRoundData();

        require(updatedAt >= block.timestamp - 24 * 3600, "stale price");

        require(rate >= 0, "rate < 0");
        return uint256(rate);
    }
}
