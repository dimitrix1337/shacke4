
const rapidrive = artifacts.require('highway')
const Token = artifacts.require("RPDToken");

contract("1 - Functional test 1", async () => {

    it("Functional test", async() => {
        const token = await Token.new()
        const rapidriveInstance = await rapidrive.new(token.address)


        await rapidriveInstance.create_ramp('campana', 'asd', 15)
        let r = await rapidriveInstance.ramps('campana');
        assert.equal(r['0'], 'campana');
        
        await rapidriveInstance.pause_contract()

        try {
            await rapidriveInstance.create_ramp('zarate', 'asd', 15)
        } catch (e) {
            console.log(e.data.stack)
        }

        await rapidriveInstance.pause_contract()

        try {
            await rapidriveInstance.create_ramp('campana', 'asd', 15)
        } catch (e) {
            console.log(e.data.stack)
        }

    })

})