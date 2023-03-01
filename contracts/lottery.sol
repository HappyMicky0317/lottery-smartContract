pragma solidity ^0.8.10;
//PDX-License-Identifier: MIT
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract lottery is VRFConsumerBase{

AggregatorV3Interface internal price_in_usd;

address owner;
address[] public players;
address winner;
uint256 proift_rate = 10;
bool winner_announced = false;
    
bytes32 internal keyHash;
uint256 internal fee;

constructor() public VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709)  // LINK Token 
    {

    keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    owner = msg.sender;
    price_in_usd = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
}


modifier onlyOwner(){
    require(msg.sender == owner);
    _;
}

uint256 entrance_Fees_USD;
bool lottery_started = false;
bool lottery_finished = false;
bool lottery_Fees_Set = false;

function set_profitrate(uint256 rate)public onlyOwner{
    require(lottery_started == false);
    proift_rate = rate;

}
function enter_lottery() public payable{
    require(lottery_Fees_Set == true,"Please wait till the owner sets the entrance fees!.");
    require(get_convertedRate(msg.value) >= entrance_Fees_USD*10**18);
    bool eligible_flag= false;
 if (players.length!=0 )
    {
    for (uint256 i =0 ; i<players.length ; i++)
        {
            if (msg.sender == players[i])
                {
                    eligible_flag = false;
                }
            else
                {
                    eligible_flag = true;
                }
        }
        
    }
    if (players.length == 0){
    eligible_flag = true;
    }

    require(eligible_flag == true , "You have already purchased the lottery ticket!.");
    players.push(msg.sender);

    


}


function start_lottery() public onlyOwner{
    lottery_started = true;
    winner_announced = false;
    
}
    
    function set_EntranceFees(uint256 fees_usd) onlyOwner public{
    require(lottery_started == false , "You cannot change the fees once the lottery has started");
    entrance_Fees_USD = fees_usd;
    lottery_Fees_Set = true;
    }

    function get_CurrentEntranceFees() public view returns(uint256){
    require(lottery_Fees_Set == true, "Owner has to set the fees first");
    uint256 current_ethRate = get_currentEthPrice();
    uint256 tempUSD = (entrance_Fees_USD+1)*10**24; //ADDING 6 EXTRA 0's TO MAKE IT 50,000000$ IF THE entrance_Fees_USD = 50. Just to ignore the issues related to decimals. 
    uint256 Fees = (tempUSD)/(current_ethRate);
    Fees = (Fees*10**12)+1000000000; //Removing 6 extra 0's that we added before. and adding some extra fees if eth/usdt price changes.
        return Fees;
    }


    function get_currentEthPrice() internal view returns(uint256) {
         
         
           (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = price_in_usd.latestRoundData();
        
     return uint256(price)*10**10;
     }


    function get_convertedRate(uint256 EthAmountSent) internal view returns (uint256){

        uint256 adjutsed_fees = get_currentEthPrice();
        uint256 price_new = (EthAmountSent*adjutsed_fees);
        price_new = price_new/10**18;
        return price_new;
}

    function end_lottery() public onlyOwner{
    require(lottery_started == true);
        lottery_finished = true;
        lottery_started = false;
        generate_randomNumber();

    }

    

    function announce_winner()  public onlyOwner{
    require(winner_announced==false,"Please wait while new lottery starts!");
    require(lottery_started == false, "Lottery in progress!");
    require(lottery_finished == true);
    require(winner != address(0),"Calculating Winner. Please try again after 4-5 minutes.");
    winner_announced = true;
    payable(winner).transfer((address(this).balance)-calculate_Ownerprofits());
    //VRF LOGIC HERE.
    //Transfer Winner funds (100-profit_rate) if profit rate = 10 then send only 90% and send 10% to owner.s
    }

    function view_winner() public view returns (address){
        require(lottery_finished == true,"Lottery not started yet or  currently in progress!");
        require(winner_announced==true,"Winner not announced yet! Try again later");
        return winner;
    }

    function reset_lottery() public onlyOwner{
        require(lottery_started == false,"You cannot end the lottery. Lottery in progress");
        address[] memory random;
        players = random;
        winner = address(0);
        lottery_finished = false;
        lottery_started = false;
    }

    function lottery_Balance() public onlyOwner view returns(uint256){
        return address(this).balance;
        
    }
    

    function calculate_Ownerprofits() public onlyOwner view returns(uint256){
        return ((address(this).balance *proift_rate)/100); 
    }

    function withdraw_profits() public onlyOwner{

        require(address(this).balance > 0,"Wallet Balance is currently 0 Wei.");
        payable(owner).transfer(address(this).balance);
    }


    function generate_randomNumber() internal {
        bytes32 requestId =  requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        winner = players[randomness%players.length];
    }

}

