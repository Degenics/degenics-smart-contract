
const Web3 = require("web3") // import web3 v1.0 constructor

// console.log(Web3)

const config = require('../truffle-config')
let network = null
var web3 = null
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
        console.log(url)
        web3 = new Web3(url);
        
        // console.log(netConf)
        // const myWeb3 = new Web3(web3.currentProvider)
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

module.exports = { getWeb3, getContractInstance }