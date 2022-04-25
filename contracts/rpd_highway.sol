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
    }
    
    struct ROUTE {
        RAMP entry;
        RAMP exit;
        uint price;
    }

    mapping(string => RAMP) public ramps;
    mapping(address => ROUTE) public in_use;
    mapping(string => ROUTE) public routes;

    constructor (RPDToken token_address) {
        TOKEN = token_address;
    }

    function pause_contract() public onlyOwner {
        paused() ? _unpause() : _pause() ;
    }

    function create_route(string memory name, string memory entry, string memory exit, uint price) public onlyOwner whenNotPaused {
        require(routes[name].price == 0, "Route already exist!");
        require(bytes(ramps[entry].name).length > 0 && bytes(ramps[entry].name).length > 0, "RAMP DOESN'T EXISTS");
        routes[name].entry = ramps[entry];
        routes[name].exit = ramps[exit];
        routes[name].price = price;
    }

    function create_ramp(string memory name, string memory location) public onlyOwner whenNotPaused {
        require(bytes(ramps[name].name).length <= 0, "RAMP ALREADY EXISTS");
        ramps[name].name = name;
        ramps[name].location = location;
    }

    function use_route(string memory route) public require_token whenNotPaused {
        require(check_allowance(), 'PLEASE CHECK YOUR BALANCE OR ALLOWANCE.');
        string memory on_ramp = routes[route].entry.name;
        string memory off_ramp = routes[route].exit.name;
        require(bytes(on_ramp).length > 0 && bytes(off_ramp).length > 0, "RAMP DOESN'T EXISTS");
        require(in_use[msg.sender].price == 0, "ALREADY USING A ROUTE, FINISH IT AND PAY IT TO USE ANOTHER.");
        in_use[msg.sender] = ROUTE(ramps[on_ramp], ramps[off_ramp], routes[route].price);

    }

    function check_allowance() public view require_token whenNotPaused returns(bool)  {
        return TOKEN.balanceOf(msg.sender) >= 10 && TOKEN.allowance(msg.sender, address(this)) >= 10;
    }

    function pay_route() external require_token whenNotPaused {
        uint amount = in_use[msg.sender].price;
        require(amount > 0, "YOU DON'T HAVE ROUTES TO PAY");
        TOKEN.transferFrom(msg.sender, address(this), amount);
        in_use[msg.sender] = ROUTE(RAMP('',''), RAMP('',''), 0);
    }


    modifier require_token() {
        require(address(TOKEN) != address(0), 'Please set correct token address');
        _;
    }

}