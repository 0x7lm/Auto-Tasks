// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { AutoTasksWithSub } from "../src/AutoTasksWithSub.sol";
import { PegSwap } from "../src/PegSwap.sol";
import { RegisterUpkeep } from "../src/RegisterUpKeep.sol";
import { Check } from "../src/chack.sol";
import { IERC20 } from "../src/interface/IERC20.sol";
import { IWETH } from "../src/interface/IWETH.sol";

contract AutoTasksWithSubTest is StdInvariant, Test {
    
    AutoTasksWithSub autoTasks;
    PegSwap pegSwap;
    RegisterUpkeep registerUpkeep;
    Check check;
    
    IWETH private weth = IWETH(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
    IERC20 private usdc = IERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);
    IERC20 private link = IERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    address private constant UNISWAP_V2_ROUTER = 0x86dcd3293C53Cf8EFd7303B57beb2a3F671dDE98;

    address constant user = address(1); 
    address constant contractToAutomate = address(2);
    string constant upkeepName = "MyUpkeep";
    string constant fnSignature = "myFunctionSignature(address,uint256)";
    string[] public args = ["0x1234567890abcdef1234567890abcdef12345678", "2"];
    uint256 constant interval = 3600;

    function setUp() public {
        check = new Check();
        registerUpkeep = new RegisterUpkeep();
        pegSwap = new PegSwap(autoTasks, registerUpkeep, check);
        autoTasks = new AutoTasksWithSub(pegSwap, check, registerUpkeep);

        // Fund the user account with ETH
        vm.deal(user, 100 ether);
    }

    function testSwapAndFund() public {
        // Swap USDC -> ETH -> LINK
        uint256 usdcAmountIn = 30e6;
        usdc.approve(address(pegSwap), usdcAmountIn);
        uint256 linkAmountOutMin = 2;
        uint256 ethAmountOutMin = 5e16;
        uint256 linkShare = 25; // 25% of 30 USDC
        uint256 ethShare = 5;   // 5% of 30 USDC
        pegSwap.swapAndFund{ value: 0 }(usdcAmountIn, linkAmountOutMin, ethAmountOutMin, linkShare, ethShare);
        
        testCreateAutomation();
    }    

    function testCreateAutomation() public {
        vm.startPrank(user);
        bool success = autoTasks.createAutomation{value: 25e6 }(
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
        autoTasks.createAutomation{value: 1 ether}(
            contractToAutomate,
            upkeepName,
            fnSignature,
            args,
            interval
        );
        vm.stopPrank();
    }
}