// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { PegSwap } from "./PegSwap.sol";
import { RegisterUpkeep } from "./RegisterUpKeep.sol";
import { Check } from "./chack.sol";

/**
 * @dev Contract for scheduling automated tasks with subscription management.
 * @author audit4me <randaljohnseo@gmail.com>
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
        bool isAutomated;
    }

    // Mapping of user address to their automation parameters
    mapping(address user => Parameters) public parameters;
    // Array to store addresses of users who have created automation tasks
    address[] public users;

    // Error declarations
    error SharesMustAddUpToTotalShares();
    error InsufficientFee();

    // Constants
    uint256 private constant USDC_SUB_FEE = 30e6;      // 30 USDC (6 decimals)
    uint256 private constant ETH_OUT = 10e14;           // 0.05 ETH in wei
    uint256 private constant TOTAL_SHARES = 100;       // 100% total shares
    uint256 private constant LINK_SHARE = 75;          // 75% of the fee to be swapped to LINK
    uint256 private constant ETH_SHARE = 25;           // 25% of the fee to be swapped to ETH
    uint256 private constant LINK_FUNDS_AMOUNT = 2e18; // 2 LINK tokens (18 decimals)
    uint32  private constant GAS_LIMIT = 500000;       // 500,000 maximum gas

    /**
     * @dev Constructor to initialize the contract with PegSwap, Check, and RegisterUpkeep contract addresses.
     * @param _pegSwap Address of the PegSwap contract.
     * @param _check Address of the Check contract.
     * @param _registerUpkeep Address of the RegisterUpkeep contract.
     */
    constructor(
        PegSwap _pegSwap,
        Check _check,
        RegisterUpkeep _registerUpkeep
    ) {
        uni = _pegSwap;
        check = _check;
        reg = _registerUpkeep;

        // Ensure the shares add up to the total shares
        if (LINK_SHARE + ETH_SHARE != TOTAL_SHARES) revert SharesMustAddUpToTotalShares();
    }

    /**
     * @dev Function to create an automation task.
     * @param _contractToAutomate Address of the contract to automate.
     * @param _upkeepName Name of the upkeep task.
     * @param _fnSignature Function signature to automate.
     * @param _args Arguments for the function.
     * @param _interval Time interval for automation.
     * @return bool indicating the success of the function.
     */
    function createAutomation(
        address _contractToAutomate,
        string memory _upkeepName,
        string memory _fnSignature,
        string[] memory _args,
        uint256 _interval
    ) public returns (bool) {

        if (
            parameters[msg.sender].contractToAutomate != address(0) ||
            bytes(parameters[msg.sender].fnSignature).length != 0
        ) {
            users.push(msg.sender);
        }

        //if ( != USDC_SUB_FEE) revert InsufficientFee();

        Parameters memory params = Parameters({
            contractToAutomate: _contractToAutomate,
            upkeepName: _upkeepName,
            fnSignature: _fnSignature,
            args: _args,
            interval: _interval,
            isAutomated: false
        });

        parameters[msg.sender] = params;

        // AutomationInfo to handle swap, funding, and registration
        automationInfo(_contractToAutomate, _upkeepName, _fnSignature, _args, _interval);

        return true;
    }

    /**
     * @dev Internal function to handle automation setup.
     * @param _contractToAutomate Address of the contract to automate.
     * @param _upkeepName Name of the upkeep task.
     * @param _fnSignature Function signature to automate.
     * @param _args Arguments for the function.
     * @param _interval Time interval for automation.
     * @return bool indicating the success of the function.
     */
    function automationInfo(
        address _contractToAutomate,
        string memory _upkeepName,
        string memory _fnSignature,
        string[] memory _args,
        uint256 _interval
    ) internal returns (bool) {

        uint256 length = users.length;

        for (uint256 i = 0; i < length; i++) {
            Parameters storage params = parameters[users[i]];
            if (!params.isAutomated) {
                // Perform the swap and fund operation
                uni.swapAndFund(USDC_SUB_FEE, LINK_FUNDS_AMOUNT, ETH_OUT, LINK_SHARE, ETH_SHARE);

                // Register the upkeep
                reg.createUpkeep(_contractToAutomate, _upkeepName, GAS_LIMIT);

                // Set the check parameters
                check.setParameters(_contractToAutomate, _fnSignature, _args, _interval);

                params.isAutomated = true;
            }
        }

        return true;
    }

    /**
     * @dev Function to get the automation parameters for a user.
     * @param _user Address of the user.
     * @return Parameters struct containing the automation details.
     */
    function getAutomation(address _user) public view returns (Parameters memory) {
        return parameters[_user];
    }    
}