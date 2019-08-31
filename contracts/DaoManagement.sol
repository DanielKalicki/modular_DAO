pragma solidity ^0.5.1;

contract DaoManagement {
    mapping(address => bool) Owners;
    
    struct Vote {
        string description;
        address creator;
        uint yea; 
        uint nay;
        uint32 voteDuration;
        uint32 finishDate;
        address proposalContractAddr;
        bytes proposalCall;
        bool executed;
    }
    Vote[] public votes; //TODO put a maximum limit?

    constructor() public{
        Owners[msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(Owners[msg.sender]);
        _;
    }
    modifier ifVoteExpired(uint256 _id){
        require(votes[_id].finishDate < block.timestamp);
        _;
    }
    modifier ifVoteDidNotExpired(uint256 _id){
        require(votes[_id].finishDate >= block.timestamp);
        _;
    }

    //voting methods
    function _majorityDecision(uint _yea, uint _nay) internal pure returns(bool){
        return (_yea > _nay);
    }
    
    //internal proposals
    function addOwner(address _owner) public{
        Owners[_owner] = true;
    }
    function removeOwner(address _owner) public{
        Owners[_owner] = false;
    }
    function changeVotingSystem() public{
        //TODO
    }

    function createVote(
        string memory _vote_description, uint32 _vote_duration, address _proposal_contract_address, bytes memory _proposal_call
    )
    onlyOwner public
    {
        //TODO only one vote per owner
        votes.push(Vote(_vote_description, msg.sender, 0, 0, _vote_duration, uint32(block.timestamp+_vote_duration), _proposal_contract_address, _proposal_call, false));
    }
    
    function executeVote(uint256 _id) public ifVoteExpired(_id) returns(bool) {
        bool bool_ret;
        bytes memory bytes_memory;
        votes[_id].executed = true;
        //TODO remove vote for list
        if (_majorityDecision(votes[_id].yea, votes[_id].nay)){
            (bool_ret, bytes_memory) = votes[_id].proposalContractAddr.call(votes[_id].proposalCall);
        }
        return bool_ret;
    }
    
    function vote(uint256 _id, bool _choice) public ifVoteDidNotExpired(_id) {
        //TODO check if user already voted
        if(_choice){
            votes[_id].yea += 1;
        }
        else{
            votes[_id].nay += 1;
        }
    }
}
