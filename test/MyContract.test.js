const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyContract", () => {
  let instance;
  let user1, user2;

  beforeEach(async () => {
    // TODO:
    // 1. get the signers
    // 2. get contract factory
    // 3. deploy with parameters
    [user1, user2] = await ethers.getSigners();
    const MyContractFactory = await ethers.getContractFactory("MyContract");
    instance = await MyContractFactory.deploy(user1.address, user2.address);
  });

  it("should return user1 and user2 correctly", async () => {
    // TODO:
    // 1. instance's user1 is equal to user1's address
    // 2. instance's user2 is equal to user2's address
    expect(await instance.user1()).to.equal(user1.address);
    expect(await instance.user2()).to.equal(user2.address);
  });

  it("instance should be able to receive token", async () => {
    // TODO:
    // 1. Create a transaction to send 1 ether to instance
    // 2. expect the transaction to be successful
    // 3. expect the instance's balance to change by 1 ether
    expect(
      user1.sendTransaction({
        to: instance.address,
        value: ethers.utils.parseEther("1.0"),
      })
    );
    console.log(tx);
    expect(
      ethers.provider.getBalance(instance.address),
      ethers.utils.parseEther("1.0")
    );
  });
});
