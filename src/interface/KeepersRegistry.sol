// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


interface KeepersRegistry {
    function getRegistrar() external view returns(address);
}