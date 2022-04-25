//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IDeBay {
    event AuctionStarted(bytes32 auctionId);
    event Bid(bytes32 auctionId, address bidder, uint256 bid);
    event AuctionEnded(bytes32 auctionId, address winner, uint256 winningBid);

    /**
    * @dev Starts an auction, emits event AuctionStarted
    * Must check if auction already exists
    */
    function startAuction(
    string calldata name,
    string calldata imgUrl,
    string calldata description,
    uint256 floor, // Minimum bid price
    uint256 deadline // To be compared with block.timestamp
    ) external;

    /**
    * @dev Bids on an auction using external funds, emits event Bid
    * Must check if auction exists && auction hasn't ended && bid isn't too low
    */
    function bid(bytes32 auctionId) external payable;

    /**
    * @dev Bids on an auction using existing funds, emits event Bid
    * Must check if auction exists && auction hasn't ended && bid isn't too low
    */
    function bid(bytes32 auctionId, uint256 amount) external;

    /**
    * @dev Settles an auction, emits event AuctionEnded
    * Must check if auction has already ended
    */
    function settle(bytes32 auctionId) external;

    /**
    * @dev Users can deposit more funds into the contract to be used for future bids
    */
    function deposit() external payable;

    /**
    * @dev Users can withdraw funds that were previously deposited
    */
    function withdraw() external;
}

contract DeBay is Ownable, Pausable, IDeBay {

        // auction struct
    struct auction {
        address initiator;
        address highest_bidder;
        address winner;
        string item_name;
        string image_url;
        string description;
        uint price_floor;
        uint deadline;
        bool finished;
    }

    function togglePause() public onlyOwner {
        // ternary operator
        (paused()) ? _unpause(): _pause();
    }

       // two mappings public
    mapping(bytes32 => auction) public auctions;
    mapping(address => uint) public userfunds;

    function startAuction(string calldata name, string calldata imgUrl, string calldata description, uint256 floor, uint256 deadline) external whenNotPaused {
        
        // creating auctionId via keccak256 like previous tasks
        (bytes32 auctionIdGenerator) = getAuctionId(msg.sender, block.timestamp + deadline * 1 hours,name, imgUrl, description);
        // setting id to auction mapping
        auctions[auctionIdGenerator] = auction(msg.sender, address(0), address(0), name, imgUrl, description, floor, block.timestamp + deadline * 1 hours, false);
    }

// a simple bid algorithm, depending if the amount is msg.value or are funds already inside in contract
    function bid_algorithm(uint amount, bytes32 auctionId) private  {

        //POINTER TO AUCTION IN STORAGE
        auction storage _auction = auctions[auctionId];
        // some requires statements to check everything is okay
        require(_auction.initiator != msg.sender);
        require(_auction.highest_bidder != msg.sender);
        require(_auction.deadline < block.timestamp, "Auction expired.");
        require(_auction.price_floor < amount, "Your bid isn't enough to replace the price floor.");
        require(_auction.highest_bidder != msg.sender, "You already are the highest bidder.");
        // if auction highest bidder is an user and then new highest bidder is come, 
        // the contract give previous bidder his respective amounts of money
        if (_auction.highest_bidder != address(0)) {
            userfunds[_auction.highest_bidder] += _auction.price_floor;
        }
        // updating new price floor and highest bidder
        _auction.price_floor =  amount;
        _auction.highest_bidder = msg.sender;

    }

    // bid via msg.value
    function bid(bytes32 auctionId) external whenNotPaused payable  {
        require(msg.value > 0);
        bid_algorithm(msg.value, auctionId);
    }

    // bid via funds inside contract    
    function bid(bytes32 auctionId, uint256 amount) external whenNotPaused  {
        require(amount > 0 && amount <= userfunds[msg.sender]);
        bid_algorithm(amount, auctionId);
        // after we need to update funds inside contract of the user , otherwise it will be exploitable
        userfunds[msg.sender] -= amount;
    }

    // settle an auction it requires deadline is passed
    function settle(bytes32 auctionId) external whenNotPaused  {
        require(auctions[auctionId].deadline <= block.timestamp && auctions[auctionId].finished == false, "Auction deadline was not reached.");
        auctions[auctionId].finished = true;
        // setting auction winner
        auctions[auctionId].winner = auctions[auctionId].highest_bidder;
    }
    
    // deposit internal funds to user 
    function deposit() external whenNotPaused payable  {
        userfunds[msg.sender] += msg.value;
    }
    
    // function to withdraw inside money of an user
    function withdraw() external whenNotPaused {
        require(userfunds[msg.sender] > 0, "You don't have saved funds.");
        uint amount = userfunds[msg.sender];
        userfunds[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // see the winner of an auction
    function see_winner(bytes32 auctionId) view external whenNotPaused returns (address) {
        return auctions[auctionId].winner;
    }

    // see highest bidder of an auction
    function see_highest_bidder(bytes32 auctionId) view external whenNotPaused returns(address) {
        return auctions[auctionId].highest_bidder;
    }
    function getAuctionId(address initiator,uint256 deadline,string calldata name,string calldata imgUrl,string calldata description) public pure returns (bytes32) {
            return keccak256(abi.encodePacked(initiator, deadline, name, imgUrl, description));
    }
}