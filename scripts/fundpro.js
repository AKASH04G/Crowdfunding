// change the address to deployed contract address
const contractAddr = "0xfA86Aef1d595D0C3A3BB80244622bb47BC2A3E32";
const { ethers } = require("ethers");
const hre = require("hardhat");
async function main() {
  const CrowdTank = await hre.ethers.getContractFactory("CrowdTank");
  const crowdTank= await CrowdTank.attach(contractAddr);

  //play around with variables
   
  const id = 101;
  const amount = "2";
  // calling the transaction
  const txn = await  crowdTank.fundProject(id,{ value: ethers.utils.parseEther(amount) });
  console.log(" Txn Status -> ",  txn.hash);
  console.log("transaction -> ",txn);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});
