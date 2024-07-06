// Change the address to your deployed contract address
const contractAddr = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const hre = require("hardhat");

async function main() {
  const CrowdTank = await hre.ethers.getContractFactory("CrowdTank");
  const crowdTank = await CrowdTank.attach(contractAddr);

  // Variables for creating a project
  const name = "Test Project";
  const description = "This is a test project description";
  const fundingGoal = hre.ethers.utils.parseEther("10"); // 10 ETH
  const durationSeconds = 1000000; // 1 week (in seconds)
  const id = 1;

  // Create a project
  let txn = await crowdTank.createProject(name, description, fundingGoal, durationSeconds, id);
  await txn.wait();
  console.log("Project created, Txn Hash -> ", txn.hash);

  // Fund the project
  const amountToFund = hre.ethers.utils.parseEther("1"); // 1 ETH
  txn = await crowdTank.fundProject(id, { value: amountToFund });
  await txn.wait();
  console.log("Project funded, Txn Hash -> ", txn.hash);

  // User withdraw funds
  txn = await crowdTank.userWithdrawFinds(id);
  await txn.wait();
  console.log("User withdrew funds, Txn Hash -> ", txn.hash);

  // Admin withdraw funds
  txn = await crowdTank.adminWithdrawFunds(id);
  await txn.wait();
  console.log("Admin withdrew funds, Txn Hash -> ", txn.hash);

  // Extend deadline
  const extendTime = 604800; // 1 week in seconds
  txn = await crowdTank.extendDeadline(id, extendTime);
  await txn.wait();
  console.log("Extended deadline, Txn Hash -> ", txn.hash);

  // Get funding percentage
  const fundPercentage = await crowdTank.fundPercentage(id);
  console.log("Funding percentage for project:", id, "is", fundPercentage.toString(), "%");

  // Check if ID is used
  const isUsed = await crowdTank.isIdUsedCall(id);
  console.log("Is project ID used:", isUsed);

  // Get total funded projects
  const totalFundedProjects = await crowdTank.getTotalFundedProjects();
  console.log("Total funded projects:", totalFundedProjects.toString());

  // Get total failed projects
  const totalFailedProjects = await crowdTank.getTotalFailedProjects();
  console.log("Total failed projects:", totalFailedProjects.toString());

  // Withdraw system admin commission
  txn = await crowdTank.systemCommission();
  await txn.wait();
  console.log("System admin commission withdrawn, Txn Hash -> ", txn.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
