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
        degenics.emitNewLab(_account, name, country, city);
    }

    function updateData(string memory field, string memory data) public onlyLab{
        eternalStorage.setString(keccak256(abi.encodePacked("lab.", field, msg.sender)), data);
    }
    
    function registerService(string memory code, string memory serviceName, string memory description, uint price, 
        string memory icon, string memory image, string memory url) public onlyLab{
        require(eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code))) == 0, "Code already register");
        Degenics degenics = Degenics(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))));
        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.service.count", msg.sender)), 1);
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code)), index);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.code", msg.sender, index )), code);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.name", msg.sender, code)), serviceName );
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.price", msg.sender, code)), price );

        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.description", msg.sender, code)), description );
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.icon", msg.sender, code)), icon );
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.image", msg.sender, code)), image );
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.url", msg.sender, code)), url );
        
        degenics.emitNewService(msg.sender, eternalStorage.getString(keccak256(abi.encodePacked("lab.name", msg.sender))),serviceName);
    }

    function addAdditionalData(string memory json) public onlyLab{
        eternalStorage.setString(keccak256(abi.encodePacked("lab.additionalData", msg.sender)), json );
    }

    function addServiceAdditionalData(string memory code, string memory jsonData) public onlyLab{
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.metadata", msg.sender, code)), jsonData);
    }

}