// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAutoTasksWithSub {
    function subscribe() external payable;
    function extendSubscription() external payable;
    function scheduleTask(uint256 interval, address target, bytes calldata data) external;
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
    function subscriptions(address user) external view returns (bool isActive, uint256 lastPayment);
    event SubscriptionRenewed(address indexed user, uint256 expiration);
}
