pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";
import "./Degenics.sol";
import "./Location.sol";
import "./Account.sol";


contract Lab is Base {

    modifier onlyLab() {
        require(roleHas("lab",msg.sender),
         "Only Lab" );
        _;
    }

    modifier onlyDegenicsContract() {
        require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender, "Only registred contract" );
        _;
    }

    constructor(address _storage ) public Base(_storage) {
    
    }

    function register(address _account, string memory name, 
        string memory country, string memory city) public onlySuperUser{

        require( eternalStorage.getUint(keccak256(abi.encodePacked("lab.index", _account))) ==0, "Already register" );

        Degenics degenics = Degenics(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))));
        Account account = Account(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Account"))));
        Location location = Location(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Location"))));

        account.register(_account, "lab");
        location.register(country, city);

        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.count")), 1);
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.index", _account)), index);

        index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.location",country, city)), 1);
        eternalStorage.setAddress(keccak256(abi.encodePacked("lab.location",country, city, index)), _account);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.name", _account)), name);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.country", _account)), country);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.city", _account)), city);
        eternalStorage.setBool(keccak256(abi.encodePacked("lab.active", _account)), false);
        degenics.emitNewLab(_account, name, country, city);
    }

    function activeLab(bool active) public onlyLab{
        eternalStorage.setBool(keccak256(abi.encodePacked("lab.active", msg.sender)), active);
    }

    function labByAccount(address _account) public view onlyDegenicsContract
        returns(address labAccount, string memory name, string memory country, string memory city,
        string memory additionalData, bool active){
           
        name = eternalStorage.getString(keccak256(abi.encodePacked("lab.name", _account)));
        country = eternalStorage.getString(keccak256(abi.encodePacked("lab.country", _account)));
        city = eternalStorage.getString(keccak256(abi.encodePacked("lab.city", _account)));         
        additionalData =  eternalStorage.getString(keccak256(abi.encodePacked("lab.additionalData", _account)));
        labAccount = _account;  
        active = eternalStorage.getBool(keccak256(abi.encodePacked("lab.active", msg.sender)));
        return (labAccount, name, country, city, additionalData, active); 
    }

    function checkActive(address labAccount, string memory code) public view onlyDegenicsContract returns(bool){
        return eternalStorage.getBool(keccak256(abi.encodePacked("lab.active", labAccount))) && eternalStorage.getBool(keccak256(abi.encodePacked("lab.service.active", labAccount, code)));
    }
    
    function registerService(string memory code, string memory serviceName, string memory description, uint price) public onlyLab{
        require(eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code))) == 0, "Code already register");
        Degenics degenics = Degenics(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))));
        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.service.count", msg.sender)), 1);
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code)), index);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.code", msg.sender, index )), code);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.name", msg.sender, code)), serviceName );
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.price", msg.sender, code)), price );
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.description", msg.sender, code)), description );
        eternalStorage.setBool(keccak256(abi.encodePacked("lab.service.active", msg.sender, code)), true);
        degenics.emitNewService(msg.sender, eternalStorage.getString(keccak256(abi.encodePacked("lab.name", msg.sender))),serviceName);
    }

    function serviceByIndex(address labAccount, uint index) public view onlyDegenicsContract returns(string memory code, 
    string memory serviceName, string memory description, uint price, string memory additionalData, bool active){
        code = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.code", labAccount, index )));
        serviceName = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.name", labAccount, code)));
        price = eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, code)));
        
        description = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.description", labAccount, code)));
        additionalData = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.additionalData", labAccount, code)));

        active = eternalStorage.getBool(keccak256(abi.encodePacked("lab.service.active", labAccount, code)));

        return(code, serviceName, description,  price, additionalData, active);
    }

    function activeService(string memory code, bool active) public onlyLab{
        eternalStorage.setBool(keccak256(abi.encodePacked("lab.service.active", msg.sender, code)), active);
    }

    function addAdditionalData(string memory json, string memory pubKey) public onlyLab{
        eternalStorage.setString(keccak256(abi.encodePacked("lab.additionalData", msg.sender)), json );
        if(bytes(eternalStorage.getString(keccak256(abi.encodePacked("pubkey", msg.sender)))).length == 0){
            eternalStorage.setString(keccak256(abi.encodePacked("pubkey", msg.sender)),  pubKey); 
        } 
    }

    function addServiceAdditionalData(string memory code, string memory jsonData) public onlyLab{
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.additionalData", msg.sender, code)), jsonData);
    }

}

//0xcba7e4441e58db5b9f63da77acec09f6833a2c44a4ef72871580ee5c41a37166