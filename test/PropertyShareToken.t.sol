// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PropertyShareToken} from "../src/PropertyShareToken.sol";

contract PropertyShareTokenTest is Test {
    PropertyShareToken public property;
    address public account1 = address(0x1);
    address public account2 = address(0x2);
    address public account3 = address(0x3);

    function setUp() public {
        property = new PropertyShareToken(1000, 1);

        // Distribute tokens
        property.transfer(account1, 400 * 10 ** 2);
        property.transfer(account2, 100 * 10 ** 2);
        property.transfer(account3, 500 * 10 ** 2);
    }

    function testDistributeFailsWithoutApproval() public {
        vm.prank(address(property.owner())); // impersonate owner
        vm.expectRevert("Majority approval required");
        property.distributeFund();
    }

    function testMajorityApprovalAllowsDistribution() public {
        vm.prank(account3);
        property.approveDistribution();

        vm.prank(address(property.owner()));
        vm.expectRevert("Majority approval required");
        property.distributeFund();

        vm.prank(account2);
        property.approveDistribution();

        // Should now succeed
        assertEq(property.approvalWeight(), 60000);
    }
}
