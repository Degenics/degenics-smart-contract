const EternalStorage = artifacts.require("EternalStorage");
const Degenics = artifacts.require("Degenics");
const Lab = artifacts.require("Lab");
const DegenicsLog = artifacts.require("DegenicsLog");
const Account = artifacts.require("Account");
const Location = artifacts.require("Location");
const SpecimenTracking = artifacts.require("SpecimenTracking");
const Specimen = artifacts.require("Specimen");
const EscrowFactory = artifacts.require("EscrowFactory");

const jsonfile = require('jsonfile');
// const { nextTick } = require('process');

const filename = './build/contract.json';

var contractInfo = {}

function addContractInfo(name, address){
    contractInfo[name] = {name, address, updated: true, lastUpdate: new Date()}
}

const listArtifact = {
    EternalStorage,
    DegenicsLog,
    Lab,
    Account, 
    Location, 
    SpecimenTracking,
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
                contractInfo.Specimen.address, contractInfo.SpecimenTracking.address, contractInfo.Location.address)
            addContractInfo(artifact.contractName, artifact.address);
            instances[artifact.contractName] = await artifact.deployed()
        }else if(artifact.contractName =="SpecimenTracking"){
            console.log('Deployed :',artifact.contractName)
            await deployer.deploy(artifact, 
                contractInfo.EternalStorage.address,
                contractInfo.DegenicsLog.address)
            addContractInfo(artifact.contractName, artifact.address);
            instances[artifact.contractName] = await artifact.deployed()
        }else if(artifact.contractName =="Specimen"){
            console.log('Deployed :',artifact.contractName)
            await deployer.deploy(artifact, 
                contractInfo.EternalStorage.address, 
                contractInfo.DegenicsLog.address, 
                contractInfo.SpecimenTracking.address)
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
            
            const labList = await jsonfile.readFileSync('./migrations/listLab.json')
            console.log(labList)

            let i = 1;
            for(let lab of labList){
                console.log(lab.name)
                await instances.Lab.register(accounts[i], lab.name, lab.country, lab.city); 
                if(lab.additionalData != undefined) await instances.Lab.addAdditionalData(JSON.stringify(lab.additionalData), {from: accounts[i]})
                if(lab.services){
                    for(let service of lab.services){
                        console.log(service)
                        await instances.Lab.registerService(service.code, service.serviceName, service.description, service.price, {from:accounts[i]});
                        if(service.additionalData) 
                            await instances.Lab.addServiceAdditionalData(service.code, JSON.stringify(service.additionalData),{from:accounts[i]})
                    }                    
                }
                i++                
            }

            let countCountry = parseInt(await instances.Location.countCountry())
            for(let i = 1; i <= countCountry; i++){
                let country = await instances.Location.countryByIndex(i)
                console.log(country)
                let countCity =await instances.Location.countCity(country)                
                for(let j =1; j <= countCity; j++){
                    let city = await instances.Location.cityByIndex(country, j)
                    console.log('----',city)
                    let countLab = await instances.Degenics.labCount(country, city)
                    for(let k = 1; k <= countLab; k++){
                        let lab = await instances.Degenics.labByIndex(country, city, k)
                        console.log('---------',lab.name)
                        let countService = await instances.Degenics.serviceCount(lab.labAccount)
                        for(let r = 1; r <= countService; r++){
                            let service =  await instances.Degenics.serviceByIndex(lab.labAccount, r)
                            console.log('-----------------', service.code, '-', service.serviceName)
                        }
                    }
                }
            }

            // console.log(countCountry)


            // await instances.Lab.register(accounts[1], 'Lab 1', 'Indenesia', 'Jakarta');
            // await instances.Lab.register(accounts[2], 'Lab 2', 'Indenesia', 'Jakarta');
            // await instances.Lab.register(accounts[3], 'Lab 3', 'Indenesia', 'Surabaya');
            // await instances.Lab.register(accounts[4], 'Lab KL', 'Malaysia', 'Kuala Lumpur');
            // await instances.Lab.register(accounts[5], 'Lab KL 1', 'Malaysia', 'Kuala Lumpur');
            // let labCount = await instances.Degenics.labCount( 'Indenesia', 'Jakarta');
            // console.log(labCount)
            // console.log(await instances.Location.countCountry())
            // console.log(await instances.Location.countryByIndex(1))
            // console.log(await instances.Location.cityByIndex("Indenesia", 1))

            // console.log(await instances.Degenics.labByIndex('Indenesia', 'Jakarta',1))
            // console.log(await instances.Degenics.labByIndex('Indenesia', 'Jakarta',2))
            // await instances.Lab.registerService('TEST-1', 'Test title 1 lab 1', 'desciption 1', 100,  {from:accounts[1]});
            // await instances.Lab.registerService('TEST-2', 'Test title 2 lab 1', 'desciption 1', 100,  {from:accounts[1]});
            // await instances.Lab.registerService('TEST-3', 'Test title 3 lab 1', 'desciption 1', 100,  {from:accounts[1]});

            // await instances.Lab.registerService('TEST-1', 'Test title 1 lab 2', 'desciption 1', 100, {from:accounts[2]});
            // await instances.Lab.registerService('TEST-2', 'Test title 2 lab 3', 'desciption 1', 100, {from:accounts[2]});

            // console.log(await instances.Degenics.serviceCount(accounts[1]))
            // console.log(await instances.Degenics.serviceCount(accounts[2]))

            // console.log(await instances.Degenics.serviceByIndex(accounts[1], 1))
            // console.log(await instances.Degenics.serviceByIndex(accounts[1], 2))
            // console.log(await instances.Degenics.serviceByIndex(accounts[1], 3))

            // await instances.Degenics.registerSpecimen(accounts[1],'TEST-3', '12123', {from: accounts[8]})
            // console.log( await instances.Degenics.getLastNumber({from: accounts[8]}))
            // await instances.Degenics.registerSpecimen(accounts[1],'TEST-1', '12123', {from: accounts[9]})
            // console.log( await instances.Degenics.getLastNumber({from: accounts[9]}))
            // await instances.Degenics.registerSpecimen(accounts[1],'TEST-2', '12123', {from: accounts[7]})
            // console.log( await instances.Degenics.getLastNumber({from: accounts[7]}))

            // let number = await instances.Degenics.getLastNumber({from: accounts[8]})
            // console.log('number', number)
            // console.log(await instances.Degenics.specimenByNumber(number))
            // let excrow = await instances.Degenics.getEscrow(number); 
            // console.log(excrow)

            // console.log(await instances.Degenics.specimenCount({from: accounts[1]}))
            // console.log(await instances.Degenics.specimenByIndex(1, {from: accounts[1]}))

            // console.log('send----------------------------------------------------------------')
            // await instances.Degenics.sendSpecimen(number, "send test", {from: accounts[8]})
            // console.log(await instances.Degenics.specimenByNumber(number))
            // console.log('receive----------------------------------------------------------------')
            // await instances.Degenics.receiveSpecimen(number, "receive test", {from: accounts[1]})
            // console.log(await instances.Degenics.specimenByNumber(number))
            // console.log('succes----------------------------------------------------------------')
            // await instances.Degenics.analysisSucces(number, "test.txt", "succes test", {from: accounts[1]})
            // console.log(await instances.Degenics.specimenByNumber(number))
            // console.log('file',await instances.Degenics.getFile(number, {from: accounts[8]}))
            // console.log('----------------------------------------------------------------')

            // let labCountSpecimen = await instances.Degenics.specimenCount({from:accounts[1]})
            // let custCountSpecimen = await instances.Degenics.specimenCount({from:accounts[8]})

            // console.log('labCountSpecimen:',labCountSpecimen, '\n','custCountSpecimen:', custCountSpecimen) 
            
            // for(let i =1; i <=labCountSpecimen; i++ ){
            //     console.log(await instances.Degenics.specimenByIndex(i, {from:accounts[1]}))
            // }

            // for(let i =1; i <=custCountSpecimen; i++ ){
            //     console.log(await instances.Degenics.specimenByIndex(i, {from:accounts[8]}))
            // }

            // console.log()




            // console.log('toBase32', await instances.Degenics.toBase32('0x2a2225a909b75597391aa279682427d26f247fc67d0b2d1afac919988ba8f5eb', {from: accounts[1]}))
            
            // console.log('toBase32', await instances.Degenics.toBase32('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', {from: accounts[1]}))

            

        } catch (error) {
            console.log('error', error)
        }
    } else if(network=='ropsten'){

    }

    for(let key in listArtifact){
        await jsonfile.writeFile(`./build/abi/${key}.json`, listArtifact[key].abi, {spaces: 2, EOL: '\r\n'});
    }

    await jsonfile.writeFile(filename, contractInfo, {spaces: 2, EOL: '\r\n'});
}