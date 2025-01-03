// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {IStrategyManager} from "../interfaces/eigen-layer/IStrategyManager.sol";
import {IStrategy} from "../interfaces/eigen-layer/IStrategy.sol";
import {IDelegationManager} from
    "../interfaces/eigen-layer/IDelegationManager.sol";
import {IRewardsCoordinator} from
    "../interfaces/eigen-layer/IRewardsCoordinator.sol";
import {
    RETH,
    EIGEN_LAYER_STRATEGY_MANAGER,
    EIGEN_LAYER_STRATEGY_RETH,
    EIGEN_LAYER_DELEGATION_MANAGER,
    EIGEN_LAYER_REWARDS_COORDINATOR,
    EIGEN_LAYER_OPERATOR
} from "../Constants.sol";
import {max} from "../Util.sol";

// TODO: remove solutions
contract EigenLayerRestake {
    IERC20 constant reth = IERC20(RETH);
    IStrategyManager constant strategyManager =
        IStrategyManager(EIGEN_LAYER_STRATEGY_MANAGER);
    IStrategy constant strategy = IStrategy(EIGEN_LAYER_STRATEGY_RETH);
    IDelegationManager constant delegationManager =
        IDelegationManager(EIGEN_LAYER_DELEGATION_MANAGER);
    IRewardsCoordinator constant rewardsCoordinator =
        IRewardsCoordinator(EIGEN_LAYER_REWARDS_COORDINATOR);

    address public owner;

    modifier auth() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // TODO: understand inputs to EigenLayer

    function deposit(uint256 rethAmount) external returns (uint256 shares) {
        reth.transferFrom(msg.sender, address(this), rethAmount);
        reth.approve(address(strategyManager), rethAmount);
        shares = strategyManager.depositIntoStrategy({
            strategy: address(strategy),
            token: RETH,
            amount: rethAmount
        });
    }

    function delegate(address operator) external auth {
        delegationManager.delegateTo({
            operator: operator,
            approverSignatureAndExpiry: IDelegationManager.SignatureWithExpiry({
                signature: "",
                expiry: 0
            }),
            approverSalt: bytes32(uint256(0))
        });
    }

    function undelegate()
        external
        auth
        returns (bytes32[] memory withdrawalRoot)
    {
        // Undelegate or queue a withdrawal
        // Undelegating from an operator automatically queues a withdrawal
        // TODO: what is withdrawalRoot used for?
        withdrawalRoot = delegationManager.undelegate(address(this));
    }

    function withdraw(address operator, uint256 _shares, uint32 startBlockNum)
        external
        auth
    {
        address[] memory strategies = new address[](1);
        strategies[0] = address(strategy);

        uint256[] memory shares = new uint256[](1);
        shares[0] = _shares;

        IDelegationManager.Withdrawal memory withdrawal = IDelegationManager
            .Withdrawal({
            staker: address(this),
            delegatedTo: operator,
            withdrawer: address(this),
            nonce: 0,
            startBlock: startBlockNum,
            strategies: strategies,
            shares: shares
        });

        address[] memory tokens = new address[](1);
        tokens[0] = RETH;

        delegationManager.completeQueuedWithdrawal({
            withdrawal: withdrawal,
            tokens: tokens,
            middlewareTimesIndex: 0,
            receiveAsTokens: true
        });
    }
    /*
        struct EarnerTreeMerkleLeaf {
            address earner;
            bytes32 earnerTokenRoot;
        }

        struct TokenTreeMerkleLeaf {
            address token;
            uint256 cumulativeEarnings;
        }

        struct RewardsMerkleClaim {
            uint32 rootIndex;
            uint32 earnerIndex;
            bytes earnerTreeProof;
            EarnerTreeMerkleLeaf earnerLeaf;
            uint32[] tokenIndices;
            bytes[] tokenTreeProofs;
            TokenTreeMerkleLeaf[] tokenLeaves;
        }

        struct DistributionRoot {
            bytes32 root;
            uint32 rewardsCalculationEndTimestamp;
            uint32 activatedAt;
            bool disabled;
        }
    */

    // root
    // - earner leaf 0
    //   - earner 0 address
    //   - earner 0 token root ------+
    // - earner leaf 1               |
    //   - earner 1 address          |
    //   - earner 1 token root       |
    // - earner leaf 2               |
    // ...                           |
    //                               |
    // earner token root <-----------+
    // - token leaf 0
    //   - token 0
    //   - cumulative earnings 0
    // - token leaf 1
    //   - token 1
    //   - cumulative earnings 1
    // - ...
    function claimRewards(IRewardsCoordinator.RewardsMerkleClaim memory claim)
        external
    {
        rewardsCoordinator.processClaim(claim, address(this));
    }

    function getShares() external view returns (uint256) {
        return strategyManager.stakerStrategyShares(
            address(this), address(strategy)
        );
    }

    function getWithdrawalDelay() external view returns (uint256) {
        uint256 protocolDelay = delegationManager.minWithdrawalDelayBlocks();

        address[] memory strategies = new address[](1);
        strategies[0] = address(strategy);
        uint256 strategyDelay = delegationManager.getWithdrawalDelay(strategies);

        return max(protocolDelay, strategyDelay);
    }

    function transfer(address token, address dst) external auth {
        IERC20(token).transfer(dst, IERC20(token).balanceOf(address(this)));
    }
}
