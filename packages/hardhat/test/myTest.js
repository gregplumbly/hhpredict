const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  beforeEach(async () => {
    // Deploy ExampleExternalContract contract
    // const [owner] = await ethers.getSigners();
    // console.log(await owner.address);

    const YourContract = await ethers.getContractFactory("YourContract");
    myContract = await YourContract.deploy();

    await myContract.createFixture("QPREVE", 222222222);
  });

  describe("Balance", () => {
    it("the balance of the pot should be zero", async () => {
      const pot = await myContract.balanceOfPot();
      expect(await pot).to.equal(0);
    });
  });

  describe("Fixtures", () => {
    it("create a fixture", async () => {
      await myContract.createFixture("LIVCHE", 1633095577);
      expect(await myContract.getMatchCount().toString()).to.equal("1");
    });
  });
});
