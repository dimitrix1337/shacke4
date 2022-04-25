// SPDX-License-Identifier: NONE

pragma solidity ^ 0.8.11;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RPDToken is ERC20, Ownable, Pausable, ReentrancyGuard {
    constructor() ERC20('RapiDrive', 'RPD') {

    }

    function buy_tokens() payable public nonReentrant() {
    
        require(msg.value >= 1 ether, "Minimum 1 ether");

        _mint(msg.sender, msg.value / 10**18);

    }
}
