//Get funds from users
// Withdraw funds
//Get a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//Long Method of Finding ABI by  Copy Pasting Solidity Interface into .sol file:
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(
//     uint80 _roundId
//   ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
// }

// Short Method of Finding ABI by Importing Interface Directly from Github
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

// this needs to be added above contract to allow for custom errors to be added to contract = error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //uint256 public myValue = 1; - this was to show a myValue to display amount of ETH on contract
    uint256 public constant MINIMUM_USD = 5 * (1e18);
    //when using constant we saved roughly 3,000 gas
    // 5 is multiplied by 10^18 to keep units uniform

    address[] public funders;
    //this is to create an array to keep track of users funding this contract
    mapping(address funder => uint256 amountFunded) public addresstoAmountFunded;

    address public immutable i_owner; //immutable keyword used on owner as it is set one time and is outside same line it was declared

    constructor() { //this is used so only contract owner can withdraw funds
        i_owner = msg.sender; 
    }

    function fund() public payable {
    //Allow users to send $
    //Have a minimum $ sent
    // How doe we send ETH to this contract?
    //myValue = myValue + 2; - this was to show when tx succeeds to add + 2 to myValue
   require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");
   // msg.value will be the first input paramater to the function where as anything in the getConversionRate will be the 2nd input paramter
    // getConversionRate links the price function below where we find the price of ETH/USD
    funders.push(msg.sender);
    // msg.sender refers to whoever calls the fund function ie person sending ETH to contract
    addresstoAmountFunded[msg.sender] = addresstoAmountFunded[msg.sender] + msg.value; //if you want to add msg.value to msg.sender you can write shorthand as addresstoAmountFunded[msg.sender] += msg.value
    

    //require(msg.value >= 1e18, "didn't send enough ETH"); // 1e18 = 1 ETH = 1 * 10 ** 18 (** means the same as ^)
    // an example is lets say after the require function there is a tonne of computation code that costs a lot of gas
    // any gas sent to carry out the rest of the computation can get reverted

    //What is a revert?
    //Reverts undo any action that have been done, and send the remaining gas back
    }

    function withdraw() public{
        // for loop allows you to withdraw a repeated amount of times
        // we loop elements [1,2,3,4] to the indexes [0,1,2,3]
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
        address funder = funders[funderIndex];
        addresstoAmountFunded[funder] = 0;
    } 
        //funderIndex++ is the same as writing FunderIndex = FunderIndex + 1
        //for(/* starting index, ending index, step amount */)
        // eg if you want to start on 0 index and go up to 10 index and go up 1 step each time
        // therefore; 0,1,2,3,4...
        //eg 2  starting index = 3 ending index = 12 step amount = 2
        //therefore 3,5,7,9,11
        // for loop will be completed once ending index is reached
    
    //to reset an array follow below:
    funders = new address[](0);
    
    
    //To withdraw funds follow 3 different ways below:

    //1) transfer funds
    //payable(msg.sender).transfer(address(this).balance); //msg.sender = address //payable(msg.sender) = payable address

    // 2) Send funds
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send failed");

    // 3) Call function to Withdraw Funds
    (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}(""); // (bool callSuccess, bytes memory dataReturned) is how its normally written but we're not interested in dataReturnes
    //callSuccess shows if withdraw funds is true or fals, dataReturned stores any data from function/values
    require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        
    require(msg.sender == i_owner, "Sender is not owner!"); // alternative is using custom errors on require functions to reduce gas cost = if (msg.sender !=i_owner) { revert NotOwner();} 
    _;} //_; executes modifier first before the function 

    //What happens if someone sends this contract ETH without calling the fund function
    //2 handy functions are 1) receive() and 2) fallback()
    receive() external payable {
        fund();
    }

    fallback() external payable{
        fund();
    }
}