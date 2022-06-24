//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Fund{

    uint256 public minUSD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmount;

    address public owner;

    constructor(){ //gets called right away
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= minUSD, "Did't seend enough");
        funders.push(msg.sender);
        addressToAmount[msg.sender] = msg.value;
    }

    function getPrice() public view returns(uint256){
        //ABI 
        //Address : 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 price, , ,) = priceFeed.latestRoundData(); //ETH in USD
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }

    function withdraw() public onlyOwner{
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }

        funders = new address[](0); //resets array
        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

}
