const { assert } = require("chai");
const { parse } = require("dotenv");

const rapidrive = artifacts.require('highway')
const Token = artifacts.require("RPDToken");

contract("HIGHWAY FUNCTIONAL TESTS", async (accounts) => {

    it("Functional test - Highway", async() => {
        const token = await Token.new()
        const rapidriveInstance = await rapidrive.new(token.address)


        await rapidriveInstance.create_ramp('campana', 'asd')
        let on_ramp = await rapidriveInstance.ramps('campana');
        assert.equal(on_ramp['0'], 'campana');
        
        await rapidriveInstance.create_ramp('ruko', 'fsd')
        let off_ramp = await rapidriveInstance.ramps('ruko');
        assert.equal(off_ramp['0'], 'ruko');   
//     function create_route(string memory name, string memory entry, string memory exit, uint price) public onlyOwner whenNotPaused {

        await rapidriveInstance.create_route('Route 1', 'campana', 'ruko', 5);
        let route = await rapidriveInstance.routes('Route 1');
        assert.equal(route['2'].toString(), '5');      

        // creating a route with same name as before, it should trigger an error
        try {
            await rapidriveInstance.create_route('Route 95', 'campana', 'ruko', 3);
        } catch (e) {
            console.log(e.data.stack)
        }
        // pausing contract and see if we can execute functions
        await rapidriveInstance.pause_contract()

        try {
            await rapidriveInstance.create_ramp('zarate', 'asd')
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.pause_contract()

        try {
            // trying to create ramp with same name as before
            // it should trigger an error of existing ramp
            await rapidriveInstance.create_ramp('campana', 'asd')
        } catch (e) {
            console.log(e.data.stack)
        }

        await token.buy_tokens({from:accounts[2] ,value: web3.utils.toWei("24", "ether" )})
        //trying using ramp without allowed contract to spend RPD TOKEN
        try {
            await rapidriveInstance.use_route('Route 1', {from:accounts[2]})
        } catch (e) {
            console.log(e.data.stack)
        }

        // approving toll system to spend tokens
        await token.approve(rapidriveInstance.address, web3.utils.toWei("10", "ether" ), {from:accounts[2]})
        
        try {
            await rapidriveInstance.use_route('Route 1', {from:accounts[2]})
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.create_ramp('escobar', 'fsd')
        await rapidriveInstance.create_route('Route 23', 'ruko', 'escobar', 6);

        // trying to use another ramp meanwhile the user already is on some of it
        try {
            await rapidriveInstance.use_route('Route 23', {from:accounts[2]})
        } catch (e) {
            console.log(e.data.stack)
        }

        let amount_before_pay = await token.balanceOf(accounts[2])

        // paying the ramp used
        try {
            await rapidriveInstance.pay_route({from:accounts[2]})
        } catch (e) {
            console.log(e)
        }

        let amount_after_pay = parseInt(await token.balanceOf(accounts[2]))

        assert.equal(parseInt((amount_after_pay)) < parseInt(amount_before_pay), true)

    })

    it("Functional test 2 - Highway ", async () => {

        const token = await Token.new()
        const rapidriveInstance = await rapidrive.new(token.address)

        await rapidriveInstance.create_ramp('rusot', 'asd')
        let r = await rapidriveInstance.ramps('rusot');
        assert.equal(r['0'], 'rusot');
        
        try {
            await rapidriveInstance.create_ramp('rusot', 'asd')
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.create_ramp('campana', 'asd')
        await rapidriveInstance.create_route('Route 23', 'campana', 'rusot', 6);

        await token.buy_tokens({value: web3.utils.toWei("50", "ether"), from:accounts[3]})
        await token.approve(rapidriveInstance.address, web3.utils.toWei("50", "ether"), {from:accounts[3]})
        let actual_money = parseInt(await token.balanceOf(accounts[3]))
        await rapidriveInstance.use_route('Route 23', {from:accounts[3]})
        
        try {
            await rapidriveInstance.use_route('Route 23', {from:accounts[3]})
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.pay_route({from:accounts[3]})

        await rapidriveInstance.use_route('Route 23', {from:accounts[3]})

        try {
            await rapidriveInstance.use_route('Route 23', {from:accounts[3]})
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.pay_route({from:accounts[3]})

        let latest_money = parseInt(await token.balanceOf(accounts[3]))

        assert.equal(latest_money < actual_money, true)

    })

})

contract("RPDTOKEN FUNCTIONAL TEST", async (accounts) => {

    it("Functional test 1 - Token", async () => {
        const token = await Token.new()

        let total_supply_before = parseInt(await token.totalSupply())
        let user_balance_before = parseInt(await token.balanceOf(accounts[5]))

        await token.buy_tokens({value: web3.utils.toWei("50", "ether"), from:accounts[5]})

        let total_supply_after = parseInt(await token.totalSupply())

        assert.equal(total_supply_after > total_supply_before, true)

        let user_balance_after = parseInt(await token.balanceOf(accounts[5]))

        assert.equal(user_balance_after > user_balance_before, true)
        assert.equal(user_balance_before, 0)
        assert.equal(user_balance_after, 50)
    })
    it("Functional test 2 - Token", async () => {
        const token = await Token.new()

        let total_supply_before = parseInt(await token.totalSupply())
        let user_balance_before = parseInt(await token.balanceOf(accounts[5]))
        assert.equal(total_supply_before, 0)

        await token.buy_tokens({value: web3.utils.toWei("50", "ether"), from:accounts[5]})

        let total_supply_after = parseInt(await token.totalSupply())

        assert.equal(total_supply_after > total_supply_before, true)

        let user_balance_before_send = parseInt(await token.balanceOf(accounts[5]))

        await token.transfer(accounts[2], 49, {from:accounts[5]})

        let user_balance_after_send = parseInt(await token.balanceOf(accounts[5]))

        assert.equal(user_balance_before_send > user_balance_after_send, true)

        let new_user_balance = parseInt(await token.balanceOf(accounts[2]))

        assert.equal(new_user_balance, 49)
        assert.equal(total_supply_after, 50)

        assert.equal(user_balance_after_send > user_balance_before, true)
        assert.equal(user_balance_before, 0)
    })

})