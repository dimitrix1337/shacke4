// SPDX-License-Identifier: NONE

pragma solidity ^ 0.8.11;

import './rpd_interface.sol';
import './rpd_token.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract highway is IRapiDrive, Ownable, Pausable {

    RPDToken TOKEN;

    struct RAMP {
        string name;
        string location;
        uint price;

    }
    mapping(address => RAMP) public in_use;
    mapping(string => RAMP) public ramps;

    constructor (RPDToken token_address) {
        TOKEN = token_address;
    }

    function pause_contract() public {
        paused() ? _pause() : _unpause();
    }

    function create_ramp(string memory name, string memory location, uint price) public onlyOwner whenNotPaused {
        require(bytes(ramps[name].name).length <= 0, "RAMP ALREADY EXISTS");
        ramps[name].name = name;
        ramps[name].location = location;
        ramps[name].price = price;
    }

    function use_ramp(string memory name) public require_token whenNotPaused {
        require(check_allowance(), 'PLEASE CHECK YOUR BALANCE OR ALLOWANCE.');
        require(bytes(ramps[name].name).length > 0, "RAMP DOESN'T EXISTS");
        require(bytes(in_use[msg.sender].name).length == 0, "ALREADY USING A RAMP, FINISH IT AND PAY IT TO USE ANOTHER.");
        in_use[msg.sender] = ramps[name];
    }

    function check_allowance() public view require_token whenNotPaused returns(bool)  {
        return TOKEN.balanceOf(msg.sender) >= 10 && TOKEN.allowance(msg.sender, address(this)) >= 10;
    }

    function pay_ramp() external require_token whenNotPaused {
        TOKEN.transferFrom(msg.sender, address(this), in_use[msg.sender].price);
        in_use[msg.sender] = RAMP('', '', 0);
    }

    modifier require_token() {
        require(address(TOKEN) != address(0), 'Please set correct token address');
        _;
    }

}