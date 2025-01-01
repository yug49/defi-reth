// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Proxy {
    // bytes32 private constant OWNER_SLOT = bytes32(uint256(keccak256("owner")) - 1);
    bytes32 private constant OWNER_SLOT =
        0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040bf;

    bytes32 constant TRANSIENT_TARGET_SLOT = 0;

    modifier auth() {
        require(msg.sender == owner(), "not authorized");
        _;
    }

    modifier set(address _target) {
        assembly {
            tstore(TRANSIENT_TARGET_SLOT, _target)
        }
        _;
        // Reset to be safe
        assembly {
            tstore(TRANSIENT_TARGET_SLOT, 0)
        }
    }

    constructor(address _owner) {
        // Store owner
        assembly {
            sstore(OWNER_SLOT, _owner)
        }
    }

    receive() external payable {}

    // Used for flash loan callback
    fallback(bytes calldata data) external payable returns (bytes memory res) {
        address addr = target();
        require(addr != address(0), "target not set");

        bool ok;
        (ok, res) = addr.delegatecall(data);
        require(ok, "fallback failed");
    }

    function owner() public view returns (address addr) {
        assembly {
            addr := sload(OWNER_SLOT)
        }
    }

    function target() private view returns (address addr) {
        assembly {
            addr := tload(TRANSIENT_TARGET_SLOT)
        }
    }

    function execute(address _target, bytes calldata data)
        external
        payable
        auth
        set(_target)
        returns (bytes memory res)
    {
        bool ok;
        (ok, res) = _target.delegatecall(data);
        require(ok, "delegatecall failed");
    }
}
