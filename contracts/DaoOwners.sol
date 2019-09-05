pragma solidity ^0.5.1;

contract DaoOwners {
    mapping (address => uint256) balances;
    uint256 total_shares;
    
    modifier onlyOwner(){
        require(balances[msg.sender] > 0);
        _;
    }
    
    constructor(uint256 _initial_shares_cnt) public{ // 100'000
        balances[msg.sender] = _initial_shares_cnt;
        total_shares = _initial_shares_cnt;
    }
    
    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }
    
    //Fundraising
    struct FundraisingOffer {
        address owner;
        uint256 amount;
        uint256 percentage;
        bool accepted;
    }
    
    FundraisingOffer[] public fundraisingOffers;
    uint32 public fundraisingEndDate = 0; // TODO public for test
    
    modifier fundraisingActive(){
        require(fundraisingEndDate >= block.timestamp);
        _;
    }
    modifier fundraisingFinished(){
        require(fundraisingEndDate < block.timestamp);
        _;
    }
 
    function startFundraising(uint256 _duration) public{
        fundraisingEndDate = uint32(block.timestamp + _duration);
    }
    
    function sendFundraisingOffer(uint256 _amount, uint256 _percentage) fundraisingActive public{
        fundraisingOffers.push(FundraisingOffer(msg.sender, _amount, _percentage, false));
    }
    
    function acceptFundraisingOffer(uint256 _id) fundraisingFinished onlyOwner public{
        fundraisingOffers[_id].accepted = true;
    }
    
    function finishFundraising() fundraisingFinished onlyOwner public {
        uint256 percentage_sum = 0;
        for (uint i = 0; i < fundraisingOffers.length; i++){
            if (fundraisingOffers[i].accepted){
                percentage_sum += fundraisingOffers[i].percentage;
            }
        }
        assert(percentage_sum < 100);
        uint256 new_shares_cnt = total_shares * 100 / percentage_sum;
        total_shares = new_shares_cnt;
        for (uint i = 0; i < fundraisingOffers.length; i++){
            if (fundraisingOffers[i].accepted){
                uint256 shares_cnt = fundraisingOffers[i].percentage * total_shares / 100;
                balances[fundraisingOffers[i].owner] = shares_cnt;
            }
        }
        fundraisingOffers.length = 0;
    }
    
    //IPO
}
