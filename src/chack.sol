// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AutomationCompatibleInterface} from "./interface/AutomationCompatibleInterface.sol";

contract Check is AutomationCompatibleInterface {
    /**
     * Public variable
     */
    bytes public outBytes;
    address private _contractAdd;
    string private _signature;
    string[] private _args;
    uint256 private lastTimeStamp;
    uint256 private interval;

    //error
    error CallFailed();

    constructor() {
        lastTimeStamp = block.timestamp;
    }

    // function to set the parameters
    function setParameters(
        address contractAdd, 
        string memory signature, 
        string[] memory args, 
        uint256 _interval
    ) public {
        _contractAdd = contractAdd;
        _signature = signature;
        _args = args;
        interval = _interval;
    }

    function callFunction(
        address addressOfContract,
        string memory signatureString,
        string[] memory arg,
        uint256 gasLimit
    ) public returns(bool) {
        (bool success, bytes memory dataReturned) = 
            addressOfContract.call{value: 200, gas: gasLimit}(abi.encodeWithSignature(signatureString, arg));
        if (!success) revert CallFailed();
        outBytes = dataReturned;
        return true;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            callFunction(_contractAdd, _signature, _args, gasleft());
        }
    }
}