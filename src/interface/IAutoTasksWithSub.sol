// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAutoTasksWithSub {
    function createAutomation(
        address _contractToAutomate, 
        string memory _upkeepName, 
        string memory _fnSignature, 
        string[] memory _args,
        uint256 _interval
    ) external payable returns (bool);
}