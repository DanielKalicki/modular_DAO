pragma solidity ^0.5.1;

contract DaoManagement {
    mapping(address => bool) Owners;
    
    struct Vote {
        string description;
        address creator;
        uint yea; 
        uint nay;
        uint32 duration;
        uint32 finishDate;
        address proposalContractAddr;
        bytes proposalCall;
        bool executed;
        mapping(address => bool) voteCast;
    }
    Vote[] public votes; //TODO put a maximum limit?
    
    bytes public abiX;
    constructor() public{
        Owners[msg.sender] = true;
        abiX = abi.encodeWithSignature("addOwner(address)", 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
    }
    
    modifier onlyOwner() {
        require(Owners[msg.sender]);
        _;
    }
    modifier voteExpired(uint256 _id){
        require(votes[_id].finishDate < block.timestamp);
        _;
    }
    modifier voteDidNotExpired(uint256 _id){
        require(votes[_id].finishDate >= block.timestamp);
        _;
    }
    modifier ownerDidNotVote(uint256 _id){
        require(votes[_id].voteCast[msg.sender]==false);
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
        
    }

    function createVote(
        string memory _description, uint32 _duration, address _proposal_contract_address, bytes memory _proposal_call
    )
    public onlyOwner
    {
        //TODO only one vote per owner
        votes.push(Vote(_description, msg.sender, 0, 0, _duration, uint32(block.timestamp+_duration), _proposal_contract_address, _proposal_call, false));
    }
    
    function executeVote(uint256 _id) public onlyOwner voteExpired(_id) returns(bool) {
        bool bool_ret;
        bytes memory bytes_memory;
        votes[_id].executed = true;
        //TODO remove vote for list
        if (_majorityDecision(votes[_id].yea, votes[_id].nay)){
            (bool_ret, bytes_memory) = votes[_id].proposalContractAddr.call(votes[_id].proposalCall);
        }
        return bool_ret;
    }
    
    function vote(
        uint256 _id, bool _choice
    )
    public onlyOwner voteDidNotExpired(_id) ownerDidNotVote(_id)
    {
        votes[_id].voteCast[msg.sender] = true;
        if(_choice){
            votes[_id].yea += 1;
        }
        else{
            votes[_id].nay += 1;
        }
    }
}
