const DaoManagement = artifacts.require("DaoManagement");
const timeHelper = require("./utils/time.js");

contract("DaoManagement", accounts => {
    it("should accept new onwer vote", () => {
        let contract_instance;
        DaoManagement.deployed()
        .then(async instance => {
            contract_instance = instance;
            let description = "add user "+accounts[1].toString()
            let contract_address = contract_instance.address
            let vote_duration = 10
            let proposal = web3.utils.toHex(web3.utils.toBN(web3.utils.toHex(
                web3.utils.keccak256("addOwner(address)").substring(0,10)+
                '000000000000000000000000'+
                accounts[1].substring(2)))
            )
            return contract_instance.createVote(description, vote_duration, contract_address, proposal)
        })
        .then(async _ => {
            let vote = await contract_instance.votes.call(0)
            assert.equal(vote.creator, accounts[0])
            assert.equal(vote.yea, 0)
            assert.equal(vote.nay, 0)
            assert.isNotTrue(vote.executed)

            return new Promise(function(resolve){resolve()})
        })
        .then(_ => contract_instance.vote(0, true, {from: accounts[0]}))
        .then(async _ => {
            await timeHelper.increaseTimeInSeconds(10)
            await timeHelper.mineBlock()
            await timeHelper.increaseTimeInSeconds(10)
            await timeHelper.mineBlock()

            let time = await timeHelper.getCurrentTime()

            return new Promise(function(resolve){resolve()})
        })
        .then(_ => contract_instance.executeVote(0, {from: accounts[0]}))
        .then(async _ => {
            let vote = await contract_instance.votes.call(0)
            assert.isTrue(vote.executed)

            return new Promise(function(resolve){resolve()})
        })
        .then(async _ => {
            let is_owner0 = await contract_instance.owners.call(accounts[0])
            let is_owner1 = await contract_instance.owners.call(accounts[1])
            let is_owner2 = await contract_instance.owners.call(accounts[2])

            assert.isTrue(is_owner0)
            assert.isTrue(is_owner1)
            assert.isNotTrue(is_owner2)
        })
    })
})
