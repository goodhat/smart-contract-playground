// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MyContract2 {
    address public user1;
    address public user2;

    event Send(address to, uint256 amount);

    constructor(address _user1, address _user2) {
        user1 = _user1;
        user2 = _user2;
    }

    function withdrawEther(address to, uint256 amount) external payable {
        require(
            msg.sender == user1 || msg.sender == user2,
            "only user1 or user2 can send"
        );
        require(address(this).balance >= amount, "insufficient balance");
        (bool success, ) = to.call{value: amount}("");
        require(success, "transfer failed");
        emit Send(to, amount);
    }
}
