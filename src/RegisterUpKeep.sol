// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface as ILinkToken }          from "./interface/LinkTokenInterface.sol";
import {KeepersRegistry }                           from "./interface/KeepersRegistry.sol";
import {AutomationRegistrarInterface as Registrar } from "./interface/AutomationRegistrarInterface.sol";
import {AutoTasksWithSub }                          from "./AutoTasksWithSub.sol";
import {IERC20 }                                    from "./interface/IERC20.sol";

contract RegisterUpkeep {
    
    // spolia testnet
    address private constant ERC677_LINK_ADDRESS = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address public constant  REGISTRY_ADDRESS = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;     
    ILinkToken ERC677Link =  ILinkToken(ERC677_LINK_ADDRESS);
    
    // uint256 public immutable interval;
    // uint256 public lastTimeStamp;
    uint8 public SOURCE = 110;
    uint public minFundingAmount = 4e18; //4 LINK
    
    /*
    register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source
    )
    */

   bytes4 private constant FUNC_SELECTOR = bytes4(keccak256("register(string,bytes,address,uint32,address,bytes,uint96,uint8)"));
  
   //Note: make sure to fund with LINK before calling createUpkeep
    function createUpkeep(address contractAddressToAutomate, string memory upkeepName, uint32 gasLimit) external {
       address registarAddress = KeepersRegistry(REGISTRY_ADDRESS).getRegistrar();
       uint96 amount = uint96(minFundingAmount);
       bytes memory data = abi.encodeWithSelector(FUNC_SELECTOR, upkeepName, hex"", contractAddressToAutomate, gasLimit, msg.sender, hex"", amount, SOURCE);
       ERC677Link.transferAndCall(registarAddress, minFundingAmount, data);
    }
    

}