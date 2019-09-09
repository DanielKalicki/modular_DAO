const DaoOwners = artifacts.require("DaoOwners");
const timeHelper = require("./utils/time.js");

function sleep(ms){
    return new Promise(resolve=>{
        setTimeout(resolve,ms)
    })
}

contract("DaoOnwers", accounts => {
    let shares_init_value = 100;
    it("should set the initial share count to 100", () => {
        DaoOwners.deployed(shares_init_value)
        .then(instance => {
            return(instance.total_shares.call())
        })
        .then(total_shares => {
            assert.equal(
                total_shares.toNumber(), shares_init_value, 'Initial shares are not set correctly'
            )
        })
    })

    it("should accept 10% fundraising offer", () => {
        let contract_instance;
        DaoOwners.deployed(100)
        .then(instance => {
            contract_instance = instance;
            return(instance.startFundraising(10, {from: accounts[0]}))
        })
        .then(async result => {
            let time = await timeHelper.getCurrentTime()
            console.log(time)
            await timeHelper.increaseTimeInSeconds(100);
            await timeHelper.mineBlock()
            time = await timeHelper.getCurrentTime()
            console.log(time)
        })
    })
})
