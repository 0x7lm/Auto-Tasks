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
    
    PegSwap private uni;
    RegisterUpkeep private reg;

    uint256 private constant USDC_SUB_FEE = 30e6;      // 6 decimals
    uint256 private constant LINK_FUNDS_AMOUNT = 5e18; // 18 decimals

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
    
    function createAutomation(address _contractToAutomate, string memory _upkeepName, uint32 _gasLimit) public payable returns (bool) {
        uni.swap(USDC_SUB_FEE, LINK_FUNDS_AMOUNT);
        reg.createUpkeep(_contractToAutomate, -_upkeepName, _gasLimit);
    }
    
}