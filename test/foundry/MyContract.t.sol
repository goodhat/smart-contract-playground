// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../../contracts/MyContract.sol";

contract MyContractTest is Test {
    MyContract myContract;
    event Received(address from, uint256 amount);

    function setUp() public {
        myContract = new MyContract(address(0), address(1));
    }

    function testUser() public {
        assertEq(myContract.user1(), address(0));
        assertEq(myContract.user2(), address(1));
    }

    function testEmitReceived() public {
        vm.expectEmit(true, true, true, false);
        emit Received(address(this), 100);
        (bool success, ) = address(myContract).call{value: 100}("");
        assert(success);
    }
}
