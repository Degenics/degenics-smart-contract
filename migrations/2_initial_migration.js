const EternalStorage = artifacts.require("EternalStorage");
const Degenics = artifacts.require("Degenics");
const Account = artifacts.require("Account");
const Location = artifacts.require("Location");
const Specimen = artifacts.require("Specimen");
const EscrowFactory = artifacts.require("EscrowFactory");

const jsonfile = require('jsonfile');
const { nextTick } = require('process');

const filename = './build/contract.json';

var contractInfo = {}

function addContractInfo(name, address){
    contractInfo[name] = {name, address, updated: true, lastUpdate: new Date()}
}

const listArtifact = {
    EternalStorage,
    Account, 
    Location, 
    Specimen,
    EscrowFactory,
    Degenics
} 


module.exports = async function(deployer,network, accounts) {

    let instances = {}

    try {
        contractInfo = await jsonfile.readFileSync(filename)
    } catch (error) {
        contractInfo = {}
    }

    for(let key in contractInfo){
        contractInfo[key].updated = false
        if(listArtifact[key] == undefined){
            console.log(`load contract ${key} - ${contractInfo[key].address}`)
            let temp = eval(key)
            instances[key] = await temp.at(contractInfo[key].address)
        } 
    }

    for(let i in listArtifact) {
        let artifact = listArtifact[i]
        if(artifact.contractName =="Degenics"){
            console.log('Deployed :',artifact.contractName)
            await deployer.deploy(artifact, 
                contractInfo.EternalStorage.address, contractInfo.Account.address, 
                contractInfo.Specimen.address, contractInfo.Location.address)
            addContractInfo(artifact.contractName, artifact.address);
            instances[artifact.contractName] = await artifact.deployed()
        } else if(artifact.abi[0].inputs.length == 0){
            console.log('Deployed :',artifact.contractName)
            await deployer.deploy(artifact)
            addContractInfo(artifact.contractName, artifact.address);
            instances[artifact.contractName] = await artifact.deployed()
        } else if(artifact.abi[0].inputs.length == 1){
            console.log('Deployed :',artifact.contractName)
            await deployer.deploy(artifact, contractInfo.EternalStorage.address)
            addContractInfo(artifact.contractName, artifact.address);
            instances[artifact.contractName] = await artifact.deployed()
        }
    }

    for(let key in contractInfo){
        if(key == 'EternalStorage') {
          continue
        }
        if(contractInfo[key].updated){
            console.log(`registry contract ${key} - ${contractInfo[key].address} - ${instances['EternalStorage'].address}`)
            let res = await instances['EternalStorage'].registryContract(key, contractInfo[key].address)
        }
    }

    if(network == 'development'){
        try {
            await instances.Degenics.registerLab(accounts[1], 'Lab 1', 'Indenesia', 'Jakarta');
            await instances.Degenics.registerLab(accounts[2], 'Lab 2', 'Indenesia', 'Jakarta');
            await instances.Degenics.registerLab(accounts[3], 'Lab 3', 'Indenesia', 'Surabaya');
            let labCount = await instances.Degenics.labCount( 'Indenesia', 'Jakarta');
            console.log(labCount)
            console.log(await instances.Degenics.labByIndex('Indenesia', 'Jakarta',1))
            console.log(await instances.Degenics.labByIndex('Indenesia', 'Jakarta',2))
            await instances.Degenics.registerService('TEST-1', 'Test ttile 1 lab 1', 100, {from:accounts[1]});
            await instances.Degenics.registerService('TEST-2', 'Test ttile 2 lab 1', 100, {from:accounts[1]});
            await instances.Degenics.registerService('TEST-3', 'Test ttile 3 lab 1', 100, {from:accounts[1]});

            await instances.Degenics.registerService('TEST-1', 'Test ttile 1 lab 2', 100, {from:accounts[2]});
            await instances.Degenics.registerService('TEST-2', 'Test ttile 2 lab 3', 100, {from:accounts[2]});

            console.log(await instances.Degenics.serviceCount(accounts[1]))
            console.log(await instances.Degenics.serviceCount(accounts[2]))

            console.log(await instances.Degenics.serviceByIndex(accounts[1], 1))
            console.log(await instances.Degenics.serviceByIndex(accounts[1], 2))
            console.log(await instances.Degenics.serviceByIndex(accounts[1], 3))

            await instances.Degenics.registerSpecimen(accounts[1],'TEST-3', {from: accounts[5]})

            let number = await instances.Degenics.getLastNumber({from: accounts[5]})
            console.log(number)
            console.log(await instances.Degenics.specimenByNumber(number))
            let excrow = await instances.Degenics.getEscrow(number); 
            console.log(excrow)

            






        } catch (error) {
            console.log(error)
        }
    }

    await jsonfile.writeFile(filename, contractInfo, {spaces: 2, EOL: '\r\n'});
}