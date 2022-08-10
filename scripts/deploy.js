// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require('hardhat');

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [root] = await hre.ethers.getSigners();

  const Bless = await hre.ethers.getContractFactory('Bless', root);
  const bless = await Bless.deploy('https://www.blessaio.com/tokens/{id}');

  console.log(bless);

  await bless.deployed();

  await bless.mint('0x5D0Ed9CAdA62CE9E5b6B2Ae6d5Db46a551fC4f00');
  await bless.mint('0x5AA0D8fd4FeBfDe39039ad7201D720E3c7B9D2f2');

  console.log('Bless deployed to:', bless.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
