// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../contracts/MyContract2.sol";

interface BAYC {
    function mintApe(uint256 amount) external payable;

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract MyContract2Test is Test {
    MyContract2 myContract;
    event Send(address to, uint256 amount);
    uint256 mainnetFork;

    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        myContract = new MyContract2(user1, user2);
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
    }

    function testOnlyUser1OrUser2CanSend() public {
        vm.deal(address(myContract), 3 ether);
        vm.prank(user1);
        myContract.withdrawEther(user1, 1 ether);
        vm.prank(user2);
        myContract.withdrawEther(user2, 1 ether);
        vm.prank(user3);
        vm.expectRevert("only user1 or user2 can send");
        myContract.withdrawEther(user3, 1 ether);
    }

    function testEmitEvent() public {
        vm.deal(address(myContract), 3 ether);
        vm.prank(user1);
        vm.expectEmit(true, true, true, false);
        emit Send(user1, 1 ether);
        myContract.withdrawEther(user1, 1 ether);
    }

    function testInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert("insufficient balance");
        myContract.withdrawEther(user1, 1 ether);
    }

    function testMintBAYC() public {
        vm.selectFork(mainnetFork);
        vm.rollFork(12299047);
        address bayc = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

        uint oldBalance = bayc.balance;
        vm.startPrank(user1);
        vm.deal(user1, 8 ether);

        for (uint i = 0; i < 5; i++) {
            BAYC(bayc).mintApe{value: 1.6 ether}(20);
            // (bool success, ) = bayc.call{value: 1.6 ether}(
            //     abi.encodeWithSignature("mintApe(uint256)", 20)
            // );
            // assert(success);
        }

        assert(BAYC(bayc).balanceOf(user1) == 100);
        assert(bayc.balance == oldBalance + 8 ether);
    }
}
