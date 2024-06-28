// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    //libraries cant have state variables and all functions have to be marked internal
    //Below we are going to get the price of ETH using a Chainlink Data Feed
    function getPrice() internal view returns (uint256) {
    //we need Address 0x694AA1769357215DE4FAC081bf1f309aDC325306 - get address from doc.chain.link - using data feeds - Sepolia ETH address
    //we need ABI - can be found using long method ABI or short method
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //( uint80 roundId, int256 price, uint256 startedAt, uint256 timestamp, uint80 answeredInRound) = priceFeed.latestRoundData();
    (, int256 price,,,) = priceFeed.latestRoundData();
    //Price of ETH in terms of US
    //Returns a large value with no decimals
    //msg.value will have 18 decimal places and we want price to have 8 decimals
    return uint256(price * 1e10); 
    }

    // function below converts msg.value in terms of dollars
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        // msg.value.getConversionRate()
        // 1 ETH = how much USD?
        uint256 ethPrice = getPrice();
        // ($3500_000000000000000000 * 1_000000000000000000) / 1e18
        // $3500 = 1 ETH
        uint256 ethAmountinUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountinUsd;
        // the reason to divide by 1e18 is because ethPrice and ethAmount have 18 decimal places
        //In Solidty, best practice is to multiply before you divide
    }

    function getVersion() internal view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}

