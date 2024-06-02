// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { LinkTokenInterface as ILinkToken } from "./interface/LinkTokenInterface.sol";
import { IUniswapV2Router01 as Router } from "./interface/IUniswapV2Router01.sol";
import { AutoTasksWithSub } from "./AutoTasksWithSub.sol";
import { IERC20 } from "./interface/IERC20.sol";
import { RegisterUpkeep } from "./RegisterUpKeep.sol";
import { Check } from "./chack.sol";

contract PegSwap {
    AutoTasksWithSub private immutable i_autoCon;
    RegisterUpkeep private immutable i_reg;
    Check private immutable i_check;
    
    // errors 
    error FailedSwap();

    // Spolia testnet addresses
    address private constant UNISWAP_V2_ROUTER = 0x86dcd3293C53Cf8EFd7303B57beb2a3F671dDE98;
    address private constant WETH = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    address private constant ETH = 0x99FCee8A75550a027Fdb674c96F2D7DA31C79fcD;
    address private constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address private constant USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    Router private immutable router;
    IERC20 private immutable weth;
    IERC20 private immutable usdc;

    constructor(AutoTasksWithSub autoCon, RegisterUpkeep reg, Check check) {
        i_autoCon = autoCon;
        i_reg = reg;
        i_check = check;
        router = Router(UNISWAP_V2_ROUTER);
        weth = IERC20(WETH);
        usdc = IERC20(USDC);
    }
    
    /**
     * @dev Swaps USDC for LINK and ETH, and funds the RegisterUpkeep and Check contracts.
     * @param amountIn The total amount of USDC to swap (e.g., 30 USDC).
     * @param linkAmountOutMin The minimum amount of LINK to receive.
     * @param ethAmountOutMin The minimum amount of ETH to receive.
     * @param linkShare The proportion of USDC to swap for LINK (e.g., 25 USDC for LINK).
     * @param ethShare The proportion of USDC to swap for ETH (e.g., 5 USDC for ETH).
     */
    function swapAndFund(
        uint256 amountIn,
        uint256 linkAmountOutMin,
        uint256 ethAmountOutMin,
        uint256 linkShare,
        uint256 ethShare
    ) external payable {
        // Transfer USDC from the user to the contract
        bool success = usdc.transferFrom(msg.sender, address(this), amountIn);
        if (!success) revert FailedSwap();
        
        // Approve the Uniswap router to spend USDC
        usdc.approve(address(router), amountIn);

        // Swap USDC to LINK
        address[] memory pathToLink = new address[](3);
        pathToLink[0] = USDC;
        pathToLink[1] = WETH;
        pathToLink[2] = LINK;
        uint256[] memory amountsLink = router.swapExactTokensForTokens(
            linkShare,
            linkAmountOutMin,
            pathToLink,
            address(i_reg), // Fund the RegisterUpkeep contract with LINK tokens
            block.timestamp
        );

        // Swap USDC to ETH
        address[] memory pathToEth = new address[](2);
        pathToEth[0] = USDC;
        pathToEth[1] = ETH;
        uint256[] memory amountsEth = router.swapExactTokensForETH(
            ethShare,
            ethAmountOutMin,
            pathToEth,
            address(i_check), // Fund the Check contract with ETH
            block.timestamp
        );

        // Refund excess USDC to the user if the actual input amount is less than the provided amount
        uint256 totalAmountUsed = amountsLink[0] + amountsEth[0];
        if (totalAmountUsed < amountIn) {
            usdc.transfer(msg.sender, amountIn - totalAmountUsed);
        }
    }
}