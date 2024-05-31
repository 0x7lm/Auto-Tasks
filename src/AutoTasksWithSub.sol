// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

//import { IERC20 }                                      from "./interface/IERC20.sol";
//import { AutomationCompatibleInterface as Automation } from "./interface/AutomationCompatibleInterface.sol";
//import { AutomationRegistrarInterface as Registrar }   from "./interface/AutomationRegistrarInterface.sol";
import {PegSwap } from "./PegSwap.sol";
import {RegisterUpkeep } from "./RegisterUpKeep.sol";

/**
 * @dev Contract for scheduling automated tasks with subscription management.
 */
contract AutoTasksWithSub {
    
    PegSwap private swap;
    RegisterUpkeep private reg;

    struct Task {
        uint256 interval;
        uint256 lastExecuted;
        address target;
        bytes data;
    }

    struct Subscription {
        bool isActive;
        uint256 lastPayment;
        uint256 taskCount;
    }
    
    function createAutomation() public view returns (bool) {
        swap.swapMultiHopExactAmountOut(amountOutDesired, amountInMax);
    }
    
}