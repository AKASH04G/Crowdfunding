// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdTank {
    // struct to store project details
    struct Project {
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
        address highestFunder;
        uint highestFund;
     }
     uint public totalFundedProjects;
    uint public totalFailedProjects;
    uint public adminCommision;
    address public systemAdmin;
    // projectId => project details
    mapping(uint => Project) public projects;
    // projectId => user => contribution amount/funding amount 
    mapping(uint => mapping(address => uint)) public contributions;

    // projectId => whether the id is used or not
    mapping(uint => bool) public isIdUsed;


    // events
    event ProjectCreated(uint indexed projectId, address indexed creator, string name, string description, uint fundingGoal, uint deadline);
    event ProjectFunded(uint indexed projectId, address indexed contributor, uint amount);
    event FundsWithdrawn(uint indexed projectId, address indexed withdrawer, uint amount, string withdrawerType);
    event userWithdrawedFund(uint indexed projectId,address indexed user,uint userFunded);
    event adminWithdrawedFunds(uint indexed projectId,address indexed admin,uint totalFunding);
    // withdrawerType = "user" ,= "admin"

    // create project by a creator
    // external public internal private
    function createProject(string memory _name, string memory _description, uint _fundingGoal, uint _durationSeconds, uint _id) external {
        require(!isIdUsed[_id], "Project Id is already used");
        isIdUsed[_id] = true;
        projects[_id] = Project({
        creator : msg.sender,
        name : _name,
        description : _description,
        fundingGoal : _fundingGoal,
        deadline : block.timestamp + _durationSeconds,
        amountRaised : 0,
        funded : false,
          highestFunder : address(0),
          highestFund:0
    
        });
        emit ProjectCreated(_id, msg.sender, _name, _description, _fundingGoal, block.timestamp + _durationSeconds);
    }

    function fundProject(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(block.timestamp <= project.deadline, "Project deadline is already passed");
        require(project.funded== false, "Project is already funded");
        require(msg.value > 0, "Must send some value of ether");
        uint amountContributed = msg.value * 95 / 100;
        uint commission = msg.value * 5 / 100;

        project.amountRaised += amountContributed;
        contributions[_projectId][msg.sender] += amountContributed;
        adminCommision+= commission;
        if (project.highestFund <= amountContributed) {
        project.highestFunder = msg.sender;
        project.highestFund = amountContributed;
    }
        emit ProjectFunded(_projectId, msg.sender, msg.value);
        if (project.amountRaised >= project.fundingGoal) {
            project.funded = true;
            totalFundedProjects+=1;
        }
        checkAndMarkFailed(_projectId);
    }

    function userWithdrawFinds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(project.amountRaised < project.fundingGoal, "Funding goal is reached,user cant withdraw");
        uint fundContributed = contributions[_projectId][msg.sender];
        payable(msg.sender).transfer(fundContributed);
        emit userWithdrawedFund(_projectId,msg.sender,fundContributed);
    }

    function adminWithdrawFunds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        uint totalFunding = project.amountRaised;
        require(project.funded, "Funding is not sufficient");
        require(project.creator == msg.sender, "Only project admin can withdraw");
        require(project.deadline <= block.timestamp, "Deadline for project is not reached");
        payable(msg.sender).transfer(totalFunding);
        emit adminWithdrawedFunds(_projectId,msg.sender,totalFunding);
    }
    //user withdraw funds before deadline
     function userwithdrawBeforeDeadline(uint  _projectId) external {
       Project storage project = projects[_projectId];
         uint fundContributed = contributions[_projectId][msg.sender];
        project.amountRaised-=fundContributed;
        payable(msg.sender).transfer(fundContributed);
        emit userWithdrawedFund(_projectId,msg.sender,fundContributed);
      }
//function   to get percentage of the fundings
function fundPercentage(uint _projectId)external view returns(uint){
    Project storage project = projects[_projectId];
   uint per=  (project.amountRaised/project.fundingGoal)*100;
   return per;
} 
//function for extending deadline
function extendDeadline(uint _projectId,uint extendTime)external {
    Project storage project = projects[_projectId];
    require(project.creator == msg.sender, "Only project admin can access and change the Deadline");
    project.deadline+= extendTime;
}
    // this is example of a read-only function
    function isIdUsedCall(uint _id)external view returns(bool){
        return isIdUsed[_id];
    }
     
     // Function to return the number of successfully funded projects
    function getTotalFundedProjects() external view returns (uint) {
        return totalFundedProjects;
    }

    // Function to return the number of failed projects
    function getTotalFailedProjects() external view returns (uint) {
        return totalFailedProjects;
    }
    //withdraw System admin commission 
    function systemCommission()external{
      require(msg.sender == systemAdmin,"System admin can access and withdraw");
      uint commission = adminCommision;
      payable(systemAdmin).transfer(commission);
    }
    //function to get failed fund making projects
    function checkAndMarkFailed(uint _projectId) internal {
        Project storage project = projects[_projectId];
        if (block.timestamp > project.deadline && !project.funded) {
            totalFailedProjects += 1;
        }
    }
}