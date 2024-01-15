// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Voting {
    struct Candidate {
        //Candidate data
        uint id;
        string name;
        string party;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates; //id mapped with candidate
    mapping(address => bool) public registeredVoter; //true if registered for voting
    mapping(address => bool) public voters; //true if voted

    uint public countCandidates; //using this as Id, voter can check details of candidate from 1 - num of candidates
    bool public votingEnd;
    bool public votingStart;

    function addCandidate(
        string memory name,
        string memory party
    ) public returns (uint) {
        countCandidates++;
        candidates[countCandidates] = Candidate(
            countCandidates,
            name,
            party,
            0
        );
        return countCandidates;
    }

    function registerForVoting() public {
        require(!registeredVoter[msg.sender], "already registered");
        require(!votingStart, "voting period started, cant register");
        registeredVoter[msg.sender] = true;
    }

    function vote(uint candidateID) public {
        //    require((votingStart <= now) && (votingEnd > now));
        require(
            votingStart == true && votingEnd == false,
            "voting period not active"
        );
        require(
            candidateID > 0 && candidateID <= countCandidates,
            "invalid candidateId"
        );

        require(registeredVoter[msg.sender], "not registered for voting");
        require(!voters[msg.sender], "you have already voted!");

        voters[msg.sender] = true;
        candidates[candidateID].voteCount++;
    }

    function checkVote() public view returns (bool) {
        return voters[msg.sender];
    }

    function getCountCandidates() public view returns (uint) {
        return countCandidates;
    }

    function getCandidate(
        uint candidateID
    ) public view returns (uint, string memory, string memory, uint) {
        return (
            candidateID,
            candidates[candidateID].name,
            candidates[candidateID].party,
            candidates[candidateID].voteCount
        );
    }

    function getWinner() public view returns (string memory) {
        require(votingEnd==true && votingStart==true);
        uint max = 1;
        uint draw;
        for (uint i = 2; i <= getCountCandidates(); ++i) {
            if (candidates[max].voteCount == candidates[i].voteCount) {
                draw = 1;
            }
            if (candidates[max].voteCount < candidates[i].voteCount) {
                max = i;
                draw = 0;
            }
        }
        // delete registeredVoter;
        return draw == 0 ? candidates[max].name : "draw";
    }

    function startVoting() public {
        require(!votingStart && votingEnd == false, "already active");
        votingStart = true;
    }

    function endVoting() public {
        require(votingStart == true, "not started");
        votingEnd = true;
        // votingStart=false;
    }
}
