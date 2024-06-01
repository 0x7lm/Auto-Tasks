# Simplified Chainlink Automated Tasks

Automating tasks on the blockchain can be complex, especially when integrating with Chainlink functions. This project simplifies the process, allowing developers to automate functions on the blockchain with just a few inputs.

## Overview

The `AutoTasksWithSub` contract streamlines the automation process by abstracting away the complexities of integrating with Chainlink. With this contract, developers can automate tasks on the blockchain using Chainlink functions with ease. Here's how it works:

1. **Simplified Automation**: Developers can automate functions on the blockchain by providing just five inputs: the address of the contract to automate, the upkeep name, the function signature, the function arguments, and the interval for task execution.

2. **Seamless Funding**: The contract handles funding automatically. Developers don't need to deal with Chainlink tokens directly. Instead, they can fund the automation process with USDC, simplifying the funding process.

3. **Automated Upkeep**: The contract takes care of creating and managing upkeeps for the automated tasks, ensuring smooth and continuous execution without manual intervention.

## Usage

To automate a function using the `AutoTasksWithSub` contract, follow these simple steps:

1. Call the `createAutomation` function with the required inputs: the address of the contract to automate, the upkeep name, the function signature, the function arguments, and the interval for task execution.
2. Fund the automation process by sending USDC to the contract. The contract will handle the rest, including swapping USDC for LINK tokens and setting up the upkeep.

## Automate Your Custem Functions

With AutoTasksWithSub, you can easily automate your own custom functions to execute at specific times. Here's how:

1. Write your custom function in your contract and make it `public`.
2. After deploying your contract, note down the function signature (e.g., `myFunction(uint256 arg1, string memory arg2)`) and the time you want it to be called.
3. Add the function signature to the `_fnSignature` parameter when calling `createAutomation` in the `AutoTasksWithSub` contract.
4. Specify the desired interval for your function to be executed.

Now sit back and watch your function execute automatically according to your specified schedule!


## Example

Here's an example of how to automate a function using the `AutoTasksWithSub` contract:

```solidity
// Instantiate the AutoTasksWithSub contract
IAutoTasksWithSub autoTasks = IAutoTasksWithSub(<AutoTasksWithSub_Address>);

// Specify the parameters for automation
address contractToAutomate = <ContractToAutomate_Address>;
string memory upkeepName = "Example Upkeep";
string memory fnSignature = "exampleFunction(uint256)";
string[] memory args = ["123", "HI"];
uint256 interval = 86400; // 1 day in seconds

// Call the createAutomation function to automate the task 
autoTasks.createAutomation{value: <USDC_Amount>}(
    contractToAutomate, 
    upkeepName, 
    fnSignature, 
    args, 
    interval
);
```

## Developer Fun

Why did the developer break up with Git?

Because they had too many unresolved conflicts! 😄

But fear not, with Chainlink Automated Tasks, you can automate your functions without any conflicts. Just a few inputs, and you're good to go! Say goodbye to manual interventions and hello to seamless automation.

Let's automate the future 🚀✨