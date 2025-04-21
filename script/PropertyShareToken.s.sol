// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PropertyShareToken} from "../src/PropertyShareToken.sol";

contract DeployPropertyShareToken is Script {
    PropertyShareToken public property;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        PropertyShareToken token = new PropertyShareToken(10000, 0);
        console.log("PropertyShareToken deployed at:", address(token));

        vm.stopBroadcast();
    }
}
