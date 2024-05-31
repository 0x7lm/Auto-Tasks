// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { LinkTokenInterface as ILinkToken } from "./interface/LinkTokenInterface.sol";
import { IUniswapV2Router01 as Router } from "./interface/IUniswapV2Router01.sol";
import { AutoTasksWithSub } from "./AutoTasksWithSub.sol";
import { IERC20 } from "./interface/IERC20.sol";
import { RegisterUpkeep } from "./RegisterUpKeep.sol";

contract PegSwap {
    AutoTasksWithSub private immutable i_autoCon;
    RegisterUpkeep private immutable i_reg;
    
    // errors 
    error FailedSwap();

    // Spolia testnet
    address private constant UNISWAP_V2_ROUTER = 0x86dcd3293C53Cf8EFd7303B57beb2a3F671dDE98;
    address private constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    address private constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address private constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    Router private immutable router;
    IERC20 private immutable weth;
    IERC20 private immutable usdc;

    constructor(AutoTasksWithSub autoCon, RegisterUpkeep reg) {
        i_autoCon = autoCon;
        i_reg = reg;
        router = Router(UNISWAP_V2_ROUTER);
        weth = IERC20(WETH);
        usdc = IERC20(USDC);
    }
    
    // Swap USDC -> WETH -> LINK 
    // to get the best deal of Link token 
    // 30$ usdc > swap to Weth > 0.02818 Wth > swap eth to LINK > 5.74136502 LINK 
    function swap(
        uint256 _amountIn,
        uint256 _amountOutMin
    ) external {

        bool success = usdc.transferFrom(msg.sender, address(this), _amountIn);
        if(!success) revert FailedSwap();
        usdc.approve(address(router), _amountIn);

        address[] memory path = new address[](3);
        path[0] = USDC;
        path[1] = WETH;
        path[2] = LINK;

        router.swapExactTokensForTokens(
          _amountIn,
          _amountOutMin,
          path,
          address(i_reg), // Found the RegisterUpkeep contract with Link token
          block.timestamp
        );
    }
}