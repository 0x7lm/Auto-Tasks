// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


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
    uint32 private constant GAS_LIMIT = 5e5;           // 500000 maximum gas function should use
    
    function createAutomation(address _contractToAutomate, string memory _upkeepName) public payable returns (bool) {
        uni.swap(USDC_SUB_FEE, LINK_FUNDS_AMOUNT);
        reg.createUpkeep(_contractToAutomate, _upkeepName, GAS_LIMIT);
        return true;
    }
    
}