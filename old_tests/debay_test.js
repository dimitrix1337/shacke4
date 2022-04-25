
const debay_instance = artifacts.require('debay')

contract("Functional test 1", async (accounts) => {
    
    it ("Should test all normal functions", async () => {
        // getting instance of deployed contract
        const debay = await debay_instance.deployed()
//    function startAuction(string calldata name, string calldata imgUrl, string calldata description, uint256 floor, uint256 deadline) external onlyNotPaused returns (bytes32) {
        await debay.togglePause()

        console.log('-------------------------------------')  
        // try send transactions while contract is paused
        try {
            
            await debay.startAuction('asd', 'asd', 'asd', 1, 2);

        }
        catch (error) {
            // catch error and console log the stack data error
            console.log(error.data.stack);

        }
        await debay.togglePause()

        // starting auction
        await debay.startAuction('asd', 'asd', 'asd', 900, 15, {from:accounts[0]});
        // getting auctionId via getAuctionId function
        var auctionId = await debay.getAuctionId(accounts[0], 1,'test1', 'asd', 'asd');
        // bidding and change the higher bidder
        try {
            await debay.bid(auctionId, {from:accounts[3], value:5000000})
            
            await debay.bid(auctionId, {from:accounts[4], value:6000000})

            debay.userfunds(accounts[3]).then(res => console.log('Accounts 3 has: ', res.toString(), ' ethers available to bid'))

            let highest = await debay.see_highest_bidder(auctionId)
            let test = (highest === accounts[4])
            assert.equal(test, true)
            console.log('NEW HIGHER BIDDER:' , highest)
        } catch (e) {
            console.log(e.data.stack)
        }

        // trying to withdraw money, if it's correct the money after withdraw should be more than before money
        web3.eth.getBalance(accounts[3]).then(res => console.log('Money before withdraw: ', res))


        await debay.withdraw({from:accounts[3]})

        web3.eth.getBalance(accounts[3]).then(result => console.log('Money AFTER the withdraw of user funds: ', result))

        // try to settle auction
        try {
            await debay.settle(auctionId)
            debay.see_winner(auctionId).then(winner => console.log('Winner: ', winner))

        } catch (e) {
            console.log(e.data.stack)
        }

        try {
            // depositing money to contract
            await debay.deposit({from:accounts[5], value:web3.utils.toWei("1", "ether")})
            const before_money = await web3.eth.getBalance(accounts[5])
            console.log(before_money)

            // withdrawing money of the contract
            await debay.withdraw({from:accounts[5]})

            const after_money = await web3.eth.getBalance(accounts[5])
            
            // asserting after_money is equal to before_money plus 1 ether (the amount deposited)
            assert.isAbove(parseInt(after_money), parseInt(before_money))

        } catch (error) {
            console.log(error)
        }

    })
})

contract("Trying to catch some errors", async (accounts) => {
    it ("It should be catch pause error", async () => {
        // creating new instance of the contract
        const debay = await debay_instance.new()
        // starting an auction
        await debay.startAuction('test1', 'asd', 'asd', 1, 15, {from:accounts[0]});

        //pausing contract
        await debay.togglePause()

        // testing the pause mode, it should catch an error
        try {
            await debay.startAuction('test2', 'asd', 'asd', 1, 15);
        } catch (e) {
            console.log(e.data.stack)
        }

        // toggle pause
        await debay.togglePause()

        // get auction id, of the previous auction created
    //     function getAuctionId(address initiator,uint256 deadline,string calldata name,string calldata imgUrl,string calldata description) public pure returns (bytes32) {

        let auctionId = await debay.getAuctionId(accounts[0], 1,'test1', 'asd', 'asd')

        // bidding to the auction
        await debay.bid(auctionId, {from:accounts[6], value:5000})
        // see if highest bidder is accounts[6]
        debay.see_highest_bidder(auctionId).then(highest_bidder => {
             assert.equal(highest_bidder, accounts[6])
             console.log('The highest bidder is: ', highest_bidder) 
            })

        // try to bid less amount than price floor, it should catch an error
        try {
            await debay.bid(auctionId, {from:accounts[5], value:2000})
        } catch (e) {
            console.log(e.data.stack)
        }

    })
})