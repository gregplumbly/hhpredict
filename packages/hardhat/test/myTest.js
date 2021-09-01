const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  beforeEach(async () => {
    // Deploy ExampleExternalContract contract

    const YourContract = await ethers.getContractFactory("YourContract");
    myContract = await YourContract.deploy();
  });

  describe("Balance", () => {
    it("the balance of the pot should be zero", async () => {
      const pot = await myContract.balanceOfPot();
      expect(await pot).to.equal(0);
    });
  });

  describe("Fixtures", () => {
    it("create a fixture", async () => {
      // const [owner] = await ethers.getSigners();
      const fixture = await myContract.createFixture("QPREVE", 222222222);
      console.log(await fixture);
    });
  });
});
