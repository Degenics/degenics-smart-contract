pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";

import "./Account.sol";
import "./Specimen.sol";
import "./Location.sol";
import "./EscrowFactory.sol";
import "./Escrow.sol";

contract Degenics is Base {

    Location location;
    Account account;
    Specimen specimen;


    event NewLab(address account, string name, string country, string city);
    event NewService(address labAccount, string name, string service);
    event NewSpecimen(address labAccount, string Code);

    
    constructor(address _storage, address _account, address _specimen, address _location ) public Base(_storage) {
        location = Location(_location);
        account = Account(_account);
        specimen = Specimen(_specimen);
    }

    

    function labCount(string memory country, string memory city) public view returns(uint){
        return  eternalStorage.getUint(keccak256(abi.encodePacked("lab.location",country, city)));
    }

    function labByIndex(string memory _country, string memory _city, uint index) public view 
        returns(address labAccount, string memory name, string memory country, string memory city, 
        string memory labAddress, string memory labLogo, string memory labUrl, string memory additionalData){
        
        labAccount = eternalStorage.getAddress(keccak256(abi.encodePacked("lab.location", _country,_city, index)));
        return labByAccount(labAccount);
    }

    function labByAccount(address _account) public view 
        returns(address labAccount, string memory name, string memory country, string memory city, 
        string memory labAddress, string memory labLogo, string memory labUrl, string memory additionalData){
           
        name = eternalStorage.getString(keccak256(abi.encodePacked("lab.name", _account)));
        country = eternalStorage.getString(keccak256(abi.encodePacked("lab.country", _account)));
        city = eternalStorage.getString(keccak256(abi.encodePacked("lab.city", _account))); 
        labAddress =  eternalStorage.getString(keccak256(abi.encodePacked("lab.address", _account)));
        labLogo  =  eternalStorage.getString(keccak256(abi.encodePacked("lab.logo", _account)));
        labUrl =  eternalStorage.getString(keccak256(abi.encodePacked("lab.url", _account)));
        additionalData =  eternalStorage.getString(keccak256(abi.encodePacked("lab.additionalData", _account)));
        labAccount = _account;  
        return (labAccount, name, country, city, labAddress, labLogo, labUrl, additionalData); 
    }

    function serviceCount(address labAccount) public view returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.count", labAccount)));
    }

    // string memory code, string memory serviceName, string memory description, uint price, 
    //     string memory icon, string memory image, string memory url

    function serviceByIndex(address labAccount, uint index) public view 
    returns(string memory code, string memory serviceName, string memory description, uint price, 
    string memory icon, string memory image, string memory url ){
        code = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.code", labAccount, index )));
        serviceName = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.name", labAccount, code)));
        price = eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, code)));
        
        description = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.description", labAccount, code)));
        icon = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.icon", labAccount, code)));
        image = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.image", labAccount, code)));
        url = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.url", labAccount, code)));

        return(code, serviceName, description,  price, icon, image, url);
    }

    function registerSpecimen(address labAccount, string memory serviceCode) public {
        
        bytes32 number = specimen.registerSpecimen(msg.sender, labAccount, serviceCode);
        address escrow = createEscrow(msg.sender, labAccount, eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, serviceCode))));

        eternalStorage.setAddress(keccak256(abi.encodePacked("Specimen.escrow", number)),  escrow); 
        emit NewSpecimen(labAccount, serviceCode);
    }

    function getLastNumber() public view returns(bytes32){
        return eternalStorage.getBytes32(keccak256(abi.encodePacked("Specimen.lastNumber",msg.sender)));
    }

    function specimenCount() public view returns(uint){
        return specimen.specimenCount(msg.sender);
    }

    function specimenByNumber(bytes32 number) public view returns(
        address owner, address labAccount, string memory serviceCode, string memory status){  
        return specimen.specimenByNumber(number) ;
    }

    function specimenByIndex(uint index) public view returns(
        address owner, address labAccount, string memory serviceCode, string memory status){        
        bytes32 number =  eternalStorage.getBytes32(keccak256(abi.encodePacked("Specimen",msg.sender, index )));   
        return specimenByNumber(number);
    }

    function getEscrow(bytes32  number) public view returns(address){
        return eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number))); 
    }

    function sendSpecimen(bytes32  number, string memory remark) public {        
        specimen.sendSpecimen(number, remark);
    }

    function receiveSpecimen(bytes32  number, string memory remark) public {
        specimen.receiveSpecimen(number, remark);
    }

    function analysisSucces(bytes32  number, string memory file, string memory remark) public {
        specimen.analysisSucces(number, file, remark);
        address payable escrowWallet = address(uint160(getEscrow(number)));
        Escrow instance = Escrow(escrowWallet);
        instance.forwardToSeller();
    }

    function analysisFail(bytes32  number, string memory remark) public {
        specimen.analysisFail(number, remark);
    }

    function escrowBalance(bytes32 number) internal view returns(uint){
        address escrow = eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number)));
        return escrow.balance;
    }

    function createEscrow(address buyer, address seller, uint amount) internal returns(address){
       address _address = eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "EscrowFactory")));
       if(_address != address(0)){
           EscrowFactory ef = EscrowFactory(_address);
           return ef.createEscrow(buyer, seller, amount);
       }
    }

    function emitNewLab(address _account, string memory name, string memory country, string memory city)public {
        emit NewLab(_account, name, country, city);
    }

    function emitNewService(address labAccount, string memory name, string memory service)public {
        emit NewService(labAccount, name, service);
    }


}

//host guitar cool sick provide magic enhance attend faith woman method episode