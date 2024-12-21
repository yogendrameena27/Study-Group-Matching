// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudyGroupMatching {
    address public owner;

    struct User {
        address userAddress;
        string name;
        string subject;
        string studyTimePreference;
        bool isRegistered;
    }

    struct StudyGroup {
        uint256 groupId;
        string subject;
        string studyTime;
        address[] members;
    }

    uint256 public groupIdCounter;
    mapping(address => User) public users;
    mapping(uint256 => StudyGroup) public studyGroups;
    mapping(address => uint256[]) public userStudyGroups;

    event UserRegistered(address userAddress, string name, string subject);
    event StudyGroupCreated(uint256 groupId, string subject, string studyTime);
    event UserAddedToGroup(address userAddress, uint256 groupId);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier isRegistered() {
        require(users[msg.sender].isRegistered, "You must be registered");
        _;
    }

    constructor() {
        owner = msg.sender;
        groupIdCounter = 0;
    }

    // Function for a user to register with their preferences
    function registerUser(string memory name, string memory subject, string memory studyTimePreference) public {
        require(!users[msg.sender].isRegistered, "You are already registered");

        users[msg.sender] = User({
            userAddress: msg.sender,
            name: name,
            subject: subject,
            studyTimePreference: studyTimePreference,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, name, subject);
    }

    // Function to create a study group based on subject and time preference
    function createStudyGroup(string memory subject, string memory studyTime) public onlyOwner {
        groupIdCounter++;
        StudyGroup storage newGroup = studyGroups[groupIdCounter];

        newGroup.groupId = groupIdCounter;
        newGroup.subject = subject;
        newGroup.studyTime = studyTime;

        emit StudyGroupCreated(groupIdCounter, subject, studyTime);
    }

    // Function for registered users to join study groups that match their preferences
    function joinStudyGroup(uint256 groupId) public isRegistered {
        StudyGroup storage group = studyGroups[groupId];
        require(bytes(group.subject).length > 0, "Group does not exist");

        // Check if the user's preferences match the group's
        require(keccak256(abi.encodePacked(users[msg.sender].subject)) == keccak256(abi.encodePacked(group.subject)), "Subject mismatch");
        require(keccak256(abi.encodePacked(users[msg.sender].studyTimePreference)) == keccak256(abi.encodePacked(group.studyTime)), "Study time mismatch");

        group.members.push(msg.sender);
        userStudyGroups[msg.sender].push(groupId);

        emit UserAddedToGroup(msg.sender, groupId);
    }

    // Function to get the list of users in a study group
    function getStudyGroupMembers(uint256 groupId) public view returns (address[] memory) {
        return studyGroups[groupId].members;
    }

    // Function to get the user's study groups
    function getUserStudyGroups() public view returns (uint256[] memory) {
        return userStudyGroups[msg.sender];
    }
}