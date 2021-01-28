
const Web3 = require("web3") // import web3 v1.0 constructor

// console.log(Web3)

const config = require('../truffle-config')
let network = null
var web3 = null
var ownerAccount 
// console.log(config)

// use globally injected web3 to find the currentProvider and wrap with web3 v1.0
const getWeb3 = async (_network) => {
    try {
        if(network==_network ){
            return web3;
        }
        network = _network   
        const netConf = config.networks[network]
        const url = `http://${netConf.host}:${netConf.port}`
        console.log(`rpc: ${url}`)
        web3 = new Web3(url);
        if(config.networks[network].provider.addresses.length > 0){
            let address = config.networks[network].provider.addresses[0]
            let wallet = config.networks[network].provider.wallets[address]
            ownerAccount =  await web3.eth.accounts
                                .privateKeyToAccount(web3.utils.bytesToHex(wallet._privKey))
        }
        return web3
    } catch (error) {
        console.log('helper getweb3')
    }
    
}

// assumes passed-in web3 is v1.0 and creates a function to receive contract name
const getContractInstance = (contractName ,web3, address)  => {
    console.log(address)
    try {
        const artifact = artifacts.require(contractName) // globally injected artifacts helper
        const instance = new web3.eth.Contract(artifact.abi, address)
        // console.log(web3, address)
        return instance     
    } catch (error) {
        console.log('helper getContractInstance', error.message)
        return null
    }
    

//   const instance = new web3.eth.Contract(artifact.abi, address)
//   return instance
}

const getOwnerAccount = () => ownerAccount

module.exports = { getWeb3, getContractInstance, getOwnerAccount }