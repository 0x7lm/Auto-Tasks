// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PegSwap } from "./PegSwap.sol";
import {RegisterUpkeep } from "./RegisterUpKeep.sol";
import {Check }  from "./chack.sol";

/**
 * @dev Contract for scheduling automated tasks with subscription management.
 */

/**
 * @title Simplified Chainlink Automated Tasks
 * @author audit4me https://github.com/audit4me
 * @notice You can automate your functions without any conflicts.
 *  Just a few inputs.
 */
contract AutoTasksWithSub {
    

    PegSwap private uni;
    Check private check;
    RegisterUpkeep private reg;

    error sharesMustBeAddUpToTotalShars();

    uint256 private constant USDC_SUB_FEE = 30e6;      // 6 decimals
    uint256 private constant ETH_OUT = 5 * 10**18; // 5 dollars in wei
    uint256 private constant TOTAL_SHARES = 100;   // 30 $
    uint256 private constant LINK_SHARE = 75;      // 75 of the 30$
    uint256 private constant ETH_SHARE = 25;       // 25 of the 30$
    uint256 private constant LINK_FUNDS_AMOUNT = 4e18; // 18 decimals
    uint32 private constant GAS_LIMIT = 5e5;           // 500000 maximum gas function should use
    

    constructor() {
        if(LINK_SHARE + ETH_SHARE != TOTAL_SHARES) revert sharesMustBeAddUpToTotalShars();
    }

    function createAutomation(
        address _contractToAutomate, 
        string memory _upkeepName, 
        string memory _fnSignature, 
        string[] memory _args,
        uint256 _interval
        ) public payable returns (bool) {
        uni.swapAndFund(USDC_SUB_FEE, LINK_FUNDS_AMOUNT, ETH_OUT, LINK_SHARE, ETH_SHARE);
        reg.createUpkeep(_contractToAutomate, _upkeepName, GAS_LIMIT);
        check.setParameters(_contractToAutomate, _fnSignature, _args, _interval);
        return true;
    }

}