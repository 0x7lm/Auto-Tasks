// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { PegSwap } from "./PegSwap.sol";
import { RegisterUpkeep } from "./RegisterUpKeep.sol";
import { Check } from "./chack.sol";

/**
 * @dev Contract for scheduling automated tasks with subscription management.
 */

/**
 * @title Simplified Chainlink Automated Tasks
 * @notice You can automate your functions without any conflicts. Just a few inputs.
 */
contract AutoTasksWithSub {
    PegSwap private immutable uni;
    Check private immutable check;
    RegisterUpkeep private immutable reg;

    struct Parameters {
        address contractToAutomate;
        string upkeepName;
        string fnSignature;
        string[] args;
        uint256 interval;
    }

    mapping(address user => Parameters) public parameters;

    error SharesMustAddUpToTotalShares();
    error insufficientFee();

    // Constants
    uint256 private constant USDC_SUB_FEE = 30e6;      // 30 USDC (6 decimals)
    uint256 private constant ETH_OUT = 5e16;           // 0.05 ETH in wei
    uint256 private constant TOTAL_SHARES = 100;       // 100% total shares
    uint256 private constant LINK_SHARE = 75;          // 75% of the fee to be swapped to LINK
    uint256 private constant ETH_SHARE = 25;           // 25% of the fee to be swapped to ETH
    uint256 private constant LINK_FUNDS_AMOUNT = 2e18; // 2 LINK tokens (18 decimals)
    uint32 private constant GAS_LIMIT = 500000;        // 500,000 maximum gas

    constructor(
        PegSwap _pegSwap,
        Check _check,
        RegisterUpkeep _registerUpkeep
    ) {
        uni = _pegSwap;
        check = _check;
        reg = _registerUpkeep;

        if (LINK_SHARE + ETH_SHARE != TOTAL_SHARES) revert SharesMustAddUpToTotalShares();
    }

    function createAutomation(
        address _contractToAutomate,
        string memory _upkeepName,
        string memory _fnSignature,
        string[] memory _args,
        uint256 _interval
    ) public payable returns (bool) {
        if(msg.value != USDC_SUB_FEE) revert insufficientFee();
        
        Parameters memory params = Parameters({
            contractToAutomate: _contractToAutomate,
            upkeepName: _upkeepName,
            fnSignature: _fnSignature,
            args: _args,
            interval: _interval
        });

        parameters[msg.sender] = params;

        // Perform the swap and fund operation
        uni.swapAndFund{value: msg.value}(USDC_SUB_FEE, LINK_FUNDS_AMOUNT, ETH_OUT, LINK_SHARE, ETH_SHARE);

        // Register the upkeep
        reg.createUpkeep(_contractToAutomate, _upkeepName, GAS_LIMIT);

        // Set the check parameters
        check.setParameters(_contractToAutomate, _fnSignature, _args, _interval);

        return true;
    }

    function getAutomation(address _user) public view returns (Parameters memory) {
        return parameters[_user];
    }    
}