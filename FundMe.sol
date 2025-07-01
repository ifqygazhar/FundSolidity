// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    address public owner;

    constructor () {
        owner = msg.sender;
    }

    using PriceConverter for uint256;

    uint256 public minimalAmmoundUsd = 5e18;
    address[] public listOfFunds;
    mapping(address funder => uint256 amountFunded) public addressToAmount;

    function fund() public payable {
        // uint256 currentConversion = PriceConverter.getConversionRate(msg.value);
        require(msg.value.getConversionRate() >= minimalAmmoundUsd,"didn't send enough of funds"); // 1 ETH 
        listOfFunds.push(msg.sender);
        addressToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 fundIndex = 0; fundIndex<listOfFunds.length; fundIndex++) 
        {
            address funder = listOfFunds[fundIndex];
            addressToAmount[funder] = 0;
            listOfFunds = new address[](0);

            //transfer
            // payable(msg.sender).transfer(address(this).balance);
            // //send
            // bool status = payable(msg.sender).send(address(this).balance);
            // require(status,"Send failed");
            //call
            //recommended
            (bool statusCall,) = payable(msg.sender).call{value: address(this).balance}("");
            require(statusCall,"Call failed");

        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner of this contract");
        _;
    }   
}