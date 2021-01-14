const hdkey = require('ethereumjs-wallet').hdkey

const wallet = hdkey.fromMasterSeed('sister write grocery keen potato tortoise carpet mushroom glue sure merge muscle')
const pairs =[]
for(let i = 0; i < 32; i++ ){
    let cWallet = wallet.deriveChild(i).getWallet()
    let o ={
        address: cWallet.getAddressString(),
        privateKey: cWallet.getPrivateKeyString(),
        publicKey: cWallet.getPublicKeyString()
    }
    pairs.push(o) 
} 

module.exports = pairs
// [
//     {address: '0x9739Aec67BfBE95a8e9228Ec056DF87a28037141', privateKey:'36fe83d7ed458c77f2f780ac47a753d4c7195ef34ce8b7fcca63b1276a7cf000'},
//     {address: '0x6C0F16DB088E52C8D58644201622db25Cd28B7Ee', privateKey:'d34e58ebf71a51e6d8db7590fb4e7d4a40f8b5b04a2c797863deee75aabe2d92' },
//     {address: '0x8101d5163ed98f71AcA2aefb590884e84cFdcD67', privateKey:'92c666f530c9939b476086d59539258040e7caa855d434d35a0611e135e5bc25'},
//     {address: '0x916eaB1B9AC0663803CA5Ef1a8aBb22108cFd19D', privateKey:'de7e610ddec992783523486bcc25ad6fdb945afed20b89e262fe73f29ceda70f'},
//     {address: '0x01288C996A36CA48D58181bAC99518ADCa0e2Bfc', privateKey:'c3018705fd876904c4d8eec83f3c92de29f16b7a3ab4de09a80d1508dc85cc03'},
//     {address: '0x066f152A2bA72A70ba86323feAC74061426A7bC1', privateKey:'aa8eaf52e17ea130ec9a5b832bee9133a34d97af103dd69fc8b54354fa7f8090'},
//     {address: '0xD833cdA13Ffef62276ebf10d091A8e35Fd2D5E00', privateKey:'aefa5e412b81f0a5d25aba48676cd7999b30b1b5c33196df18129b915b58d48b'},
//     {address: '0xa8B8F4a7783aa30113F2D843f19d629738B0F0ff', privateKey:'561c3b6dea3fbc9474e550d0006dd6932c7e0dd453bc991a941c9f5026d4c8ad'},
//     {address: '0x3D79AE783D2a769d8BbbFE4A726EC9879Da94576', privateKey:'fd1bc8129053d852b848f238b68b97b20d83e659a8e4d693ed65e67ebf8db930'},
// ]