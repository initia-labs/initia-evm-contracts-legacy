// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {InitiaCustomERC20} from "../src/InitiaCustomERC20.sol";

contract NewInitiaERC20Script is Script {
    /**
     * @dev Relevant source part starts here and spans across multiple lines
     */
    function setUp() public {}

    /**
     * @dev Main deployment script
     */
    function run() public {
        // Setup
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy
        InitiaCustomERC20 erc20 = new InitiaCustomERC20("TEST", "Tst", 18);
    }
}
