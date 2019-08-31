pragma solidity ^0.5.1;
//pragma experimental ABIEncoderV2;
import "./PaySomeone.sol";

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
        //bytes4 fnExecute;
    }
    Vote[] public votes; //put a maximum limit?

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

    //voting methods
    function _majorityDecision(uint _yea, uint _nay) internal pure returns(bool){
        return (_yea > _nay);
    }
    
    //internal proposals
    //addOwner
    //removeOwner

    //"test 6","0","10"
    //0xd53fFE9d4585B641b997e327D928Eb2A6E1c5F55
    //0x2b0969260000000000000000000000000000000000000000000000000000000000000002
    function createVote(
        string memory _vote_description, uint32 _vote_duration, address _proposal_contract_address, bytes memory _proposal_call
    )
    onlyOwner public
    {
        //only one vote per owner
        votes.push(Vote(_vote_description, msg.sender, 0, 0, _vote_duration, uint32(block.timestamp+_vote_duration), _proposal_contract_address, _proposal_call));
    }
    
    //function executeVote(uint256 _id) public ifVoteExpired(_id) returns(bool) {
    function executeVote(uint256 _id) public returns(bool) {
        bool bool_ret;
        bytes memory bytes_memory;
        (bool_ret, bytes_memory) = votes[_id].proposalContractAddr.call(votes[_id].proposalCall);
        return bool_ret;
    }
}

