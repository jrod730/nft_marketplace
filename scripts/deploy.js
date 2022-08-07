const hre = require('hardhat');

async function main() {
  const NftMarketplace = await hre.ethers.getContractFactory('NftMarketplace');
  const nftMarketplace = await NftMarketplace.deploy();

  await nftMarketplace.deployed();

  console.log('NftMarketplace deployed to:', nftMarketplace.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
