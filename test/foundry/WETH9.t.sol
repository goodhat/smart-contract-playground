// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/StdUtils.sol";
import "../../contracts/WETH9.sol";

contract WETH9Test is Test {
    WETH9 weth;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);

    function setUp() public {
        weth = new WETH9();
    }

    // test 1
    function testDepositValueShouldEqualToMintedToken() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        weth.deposit{value: 1 ether}();
        assertEq(weth.balanceOf(user1), 1 ether);
    }

    // test 2
    function testWethShouldGetDeposit() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        weth.deposit{value: 1 ether}();
        assertEq(address(weth).balance, 1 ether);
    }

    // test 3
    function testDepositShouldEmitEvent() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectEmit(true, true, false, false);
        emit Transfer(address(0), user1, 1 ether);
        weth.deposit{value: 1 ether}();
    }

    // test 4
    function testWithdrawShouldBurnToken() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);
        weth.deposit{value: 1 ether}();
        uint oldTotalSupply = weth.totalSupply();
        uint oldBalance = weth.balanceOf(user1);
        weth.withdraw(1 ether);
        uint newTotalSupply = weth.totalSupply();
        uint newBalance = weth.balanceOf(user1);
        assertEq(oldTotalSupply - 1 ether, newTotalSupply);
        assertEq(oldBalance - 1 ether, newBalance);
    }

    // test 5
    function testWithdrawShouldReturnEther() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);
        weth.deposit{value: 1 ether}();
        uint oldBalance = user1.balance;
        weth.withdraw(1 ether);
        uint newBalance = user1.balance;
        assertEq(oldBalance + 1 ether, newBalance);
    }

    // test 6
    function testWithdrawShouldEmitEvent() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);
        weth.deposit{value: 1 ether}();
        vm.expectEmit(true, true, false, false);
        emit Transfer(user1, address(0), 1 ether);
        weth.withdraw(1 ether);
    }

    // test 7
    function testTransferShouldTransferToken() public {
        deal(address(weth), user1, 1 ether);
        vm.startPrank(user1);
        assertEq(weth.balanceOf(user1), 1 ether);
        assertEq(weth.balanceOf(user2), 0);
        weth.transfer(user2, 1 ether);
        assertEq(weth.balanceOf(user1), 0);
        assertEq(weth.balanceOf(user2), 1 ether);
    }

    function testTransferShouldEmitEvent() public {
        deal(address(weth), user1, 1 ether);
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false);
        emit Transfer(user1, user2, 1 ether);
        weth.transfer(user2, 1 ether);
    }

    // test 8
    function testApprove() public {
        vm.startPrank(user1);
        weth.approve(user2, 1 ether);
        assertEq(weth.allowance(user1, user2), 1 ether);
    }

    function testApproveShouldEmitEvent() public {
        vm.startPrank(user1);
        vm.expectEmit(true, true, false, false);
        emit Approval(user1, user2, 1 ether);
        weth.approve(user2, 1 ether);
    }

    // test 9
    function testTransferFromShouldUseAllowance() public {
        deal(address(weth), user1, 1 ether);
        assertEq(weth.balanceOf(user1), 1 ether);
        assertEq(weth.balanceOf(user3), 0);
        vm.startPrank(user1);
        weth.approve(user2, 1 ether);
        changePrank(user2);
        weth.transferFrom(user1, user3, 1 ether);
        assertEq(weth.balanceOf(user1), 0);
        assertEq(weth.balanceOf(user3), 1 ether);
    }

    function testTransferFromShouldEmitEvent() public {
        deal(address(weth), user1, 1 ether);
        vm.startPrank(user1);
        weth.approve(user2, 1 ether);
        changePrank(user2);
        vm.expectEmit(true, true, false, false);
        emit Transfer(user1, user3, 1 ether);
        weth.transferFrom(user1, user3, 1 ether);
    }

    // test 10
    function testTransferFromShouldSubstractAllowance() public {
        deal(address(weth), user1, 2 ether);
        vm.startPrank(user1);
        weth.approve(user2, 2 ether);
        assertEq(weth.allowance(user1, user2), 2 ether);
        changePrank(user2);
        weth.transferFrom(user1, user3, 1 ether);
        assertEq(weth.allowance(user1, user2), 1 ether);
    }

    function testTransferFromShouldRevertWithInsufficientAllowance() public {
        deal(address(weth), user1, 2 ether);
        vm.startPrank(user1);
        weth.approve(user2, 1 ether);
        changePrank(user2);
        vm.expectRevert();
        weth.transferFrom(user1, user3, 2 ether);
    }

    function testWithdrawShouldRevertWithInsufficientBalance() public {
        deal(address(weth), user1, 1 ether);
        vm.startPrank(user1);
        vm.expectRevert("Insufficient");
        weth.withdraw(2 ether);
    }
}
