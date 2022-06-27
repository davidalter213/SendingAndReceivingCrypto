//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();

contract Fund{
    using PriceConverter for uint256;

    uint256 public constant MINUSD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmount;

    address public immutable i_owner;

    constructor(){ //gets called right away
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINUSD, "Did't seend enough");
        funders.push(msg.sender);
        addressToAmount[msg.sender] += msg.value;
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
        //require(msg.sender == i_owner, "You are not the owner");
        if (msg.sender != i_owner) {revert NotOwner();}
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}
