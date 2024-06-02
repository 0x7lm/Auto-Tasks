// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {AutoTasksWithSub } from "../src/AutoTasksWithSub.sol";
import { PegSwap }         from "../src/PegSwap.sol";
import { RegisterUpkeep }  from "../src/RegisterUpKeep.sol";
import { Check }           from "../src/chack.sol";

contract MyScript is Script {

    PegSwap pegSwap;
    AutoTasksWithSub autoTasks;
    Check check;
    RegisterUpkeep registerUpkeep;

    function run() external {

        check = new Check();
        registerUpkeep = new RegisterUpkeep();
        pegSwap = new PegSwap(autoTasks, registerUpkeep, check);
        autoTasks = new AutoTasksWithSub(pegSwap, check, registerUpkeep);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AutoTasksWithSub atw = new AutoTasksWithSub(pegSwap, check, registerUpkeep);

        vm.stopBroadcast();
    }
}
