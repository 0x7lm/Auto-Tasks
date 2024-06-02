// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test}              from "forge-std/Test.sol";
import {StdInvariant}      from "forge-std/StdInvariant.sol";
import {console}           from "forge-std/console.sol";
import {AutoTasksWithSub } from "../src/AutoTasksWithSub.sol";
import {PegSwap }          from "../src/PegSwap.sol";
import {RegisterUpkeep }   from "../src/RegisterUpKeep.sol";
import {Check}             from "../src/chack.sol";

contract AutoTasksWithSubTest is StdInvariant, Test {
    
    AutoTasksWithSub autoTasks;
    PegSwap pegSwap;
    RegisterUpkeep registerUpkeep;
    Check check;

    address constant user = address(1);
    address constant contractToAutomate = address(2);
    string constant upkeepName = "MyUpkeep";
    string constant fnSignature = "myFunctionSignature(address,uint256)";
    string[] public args = ["0x1234567890abcdef1234567890abcdef12345678", "2"] ;
    uint256 constant interval = 3600;

    function setUp() public {
        check = new Check();
        registerUpkeep = new RegisterUpkeep();
        pegSwap = new PegSwap(autoTasks, registerUpkeep, check);
        autoTasks = new AutoTasksWithSub(pegSwap, check, registerUpkeep);
        
        vm.deal(user, 100 ether);
        
        // // args as string
        // arg[] = new args;
        // args[0] = "0x1234567890abcdef1234567890abcdef12345678";
        // args[1] = "23";
    }

    function testCreateAutomation() public {
        vm.startPrank(user);
        bool success = autoTasks.createAutomation{value: 30 ether}(
            contractToAutomate,
            upkeepName,
            fnSignature,
            args,
            interval
        );
        assertTrue(success);

        AutoTasksWithSub.Parameters memory params = autoTasks.getAutomation(user);
        assertEq(params.contractToAutomate, contractToAutomate);
        assertEq(params.upkeepName, upkeepName);
        assertEq(params.fnSignature, fnSignature);
        assertEq(params.args[0], args[0]);
        assertEq(params.args[1], args[1]);
        assertEq(params.interval, interval);
        vm.stopPrank();
    }

    function testFailCreateAutomationInsufficientFee() public {
        vm.startPrank(user);
        vm.expectRevert();
        autoTasks.createAutomation{value: 10 ether}(
            contractToAutomate,
            upkeepName,
            fnSignature,
            args,
            interval
        );
        vm.stopPrank();
    }
}
