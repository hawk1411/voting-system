// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleVoting
 * @dev Ethereum voting system with admin-controlled proposal creation.
 *      - Admin registers voters.
 *      - Admin sets one proposal with two options.
 *      - Each registered voter can vote once.
 *      - Double voting is prevented.
 *      - Voting has a deadline.
 *      - Anyone can check results after voting ends.
 */
contract SimpleVoting {
    address public admin;             // Admin (contract deployer)
    uint256 public votingEndTime;     // Voting deadline

    string public proposal;           // Proposal text
    string public optionA;            // Option A name
    string public optionB;            // Option B name

    mapping(address => bool) public isRegistered; // Tracks registered voters
    mapping(address => bool) public hasVoted;     // Tracks who voted

    uint256 public votesForA; // Vote count for Option A
    uint256 public votesForB; // Vote count for Option B

    // Events
    event Registered(address voter);
    event Voted(address voter, string option);

    /**
     * @dev Constructor sets the admin, voting duration, and proposal with options.
     * @param _durationInMinutes Voting duration in minutes
     * @param _proposal Proposal description
     * @param _optionA Name of option A
     * @param _optionB Name of option B
     */
    constructor(
        uint256 _durationInMinutes,
        string memory _proposal,
        string memory _optionA,
        string memory _optionB
    ) {
        admin = msg.sender;
        votingEndTime = block.timestamp + (_durationInMinutes * 1 minutes);

        proposal = _proposal;
        optionA = _optionA;
        optionB = _optionB;
    }

    /**
     * @dev Register voters (admin only)
     * @param voters Array of addresses to register
     */
    function registerVoters(address[] calldata voters) external {
        require(msg.sender == admin, "Only admin can register voters");

        for (uint256 i = 0; i < voters.length; i++) {
            if (!isRegistered[voters[i]]) {
                isRegistered[voters[i]] = true;
                emit Registered(voters[i]);
            }
        }
    }

    /**
     * @dev Cast a vote (registered voters only)
     * @param voteForA True = vote for option A, False = vote for option B
     */
    function vote(bool voteForA) external {
        require(block.timestamp <= votingEndTime, "Voting period has ended");
        require(isRegistered[msg.sender], "You are not a registered voter");
        require(!hasVoted[msg.sender], "You have already voted");

        hasVoted[msg.sender] = true;

        if (voteForA) {
            votesForA += 1;
            emit Voted(msg.sender, optionA);
        } else {
            votesForB += 1;
            emit Voted(msg.sender, optionB);
        }
    }

    /**
     * @dev Get the winning option after voting ends
     * @return result Winning option or tie
     */
    function getResult() external view returns (string memory result) {
        require(block.timestamp > votingEndTime, "Voting is still ongoing");

        if (votesForA > votesForB) {
            return string(abi.encodePacked(optionA, " Wins"));
        } else if (votesForB > votesForA) {
            return string(abi.encodePacked(optionB, " Wins"));
        } else {
            return "It's a Tie";
        }
    }
}
