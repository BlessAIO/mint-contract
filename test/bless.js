const chai = require('chai');
const { ethers } = require('hardhat');
const { solidity } = require('ethereum-waffle');
const { expect } = chai;

chai.use(solidity);

const MASTER_CONFIG = {
  uri: 'https://www.blessaio.com/tokens/{id}',
};

const getAccounts = async () => {
  const accounts = await ethers.getSigners();
  return {
    root: accounts[0],
  };
};

const getInstanceContract = async signer => {
  const Bless = await ethers.getContractFactory('Bless', signer);

  const bless = await Bless.deploy(MASTER_CONFIG.uri);

  return bless;
};

describe('Bless', function() {
  beforeEach(async function() {
    this.accounts = await getAccounts();

    this.contract = await getInstanceContract(this.accounts.root);
  });

  describe('Deploy', function() {
    it('should return uri valid', async function() {
      const uri = await this.contract.uri(1);

      expect(uri).to.be.equal(MASTER_CONFIG.uri);
    });
  });

  describe('Mint', function() {
    it('should return uri valid', async function() {
      const uri = await this.contract.uri(1);

      expect(uri).to.be.equal(MASTER_CONFIG.uri);
    });
  });
});
