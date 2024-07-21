// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {InitiaERC20} from "evm-contracts/initia_erc20/InitiaERC20.sol";

contract InitiaERC20Script is Script {
    /**
     * @dev Relevant source part starts here and spans across multiple lines
     */
    function setUp() public {
    }

    /**
     * @dev Main deployment script
     */
    function run() public {
        // Setup
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy
        new InitiaERC20("BASE", "BE", 18);
    }
}