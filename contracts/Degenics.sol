pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";

import "./Account.sol";
import "./SpecimenTracking.sol";
import "./Specimen.sol";
import "./Location.sol";
import "./EscrowFactory.sol";
import "./Escrow.sol";
import "./Lab.sol";

contract Degenics is Base {

    Location location;
    Account account;
    Specimen specimen;
    SpecimenTracking specimenTracking;

    mapping(address => string)  private lastNumber;


    event NewLab(address account, string name, string country, string city);
    event NewService(address labAccount, string name, string service);
    event NewSpecimen(address labAccount, string Code);

    
    constructor(address _storage, address _account, address _specimen, address _specimenTracking, address _location ) public Base(_storage) {
        location = Location(_location);
        account = Account(_account);
        specimen = Specimen(_specimen);
        specimenTracking = SpecimenTracking(_specimenTracking);
    }

    

    function labCount(string memory country, string memory city) public view returns(uint){
        return  eternalStorage.getUint(keccak256(abi.encodePacked("lab.location",country, city)));
    }

    function labByIndex(string memory _country, string memory _city, uint index) public view 
        returns(address labAccount, string memory name, string memory country, string memory city, 
        string memory additionalData, bool active){
        
        labAccount = eternalStorage.getAddress(keccak256(abi.encodePacked("lab.location", _country,_city, index)));
        return labByAccount(labAccount);
    }

    function labByAccount(address _account) public view 
        returns(address labAccount, string memory name, string memory country, string memory city,
        string memory additionalData, bool active){
        
        return getLabInstance().labByAccount(_account);
    }

    function serviceCount(address labAccount) public view returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.count", labAccount)));
    }

    
    function serviceByIndex(address labAccount, uint index) public view 
    returns(string memory code, string memory serviceName, string memory description, uint price, string memory additionalData, 
    bool active){
        
        return getLabInstance().serviceByIndex(labAccount, index);
    }

    function registerSpecimen(address labAccount, string memory serviceCode, string memory pubKey) public {
        
        string memory number = specimen.registerSpecimen(msg.sender, labAccount, serviceCode);
        address escrow = createEscrow(msg.sender, labAccount, eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, serviceCode))));

        eternalStorage.setAddress(keccak256(abi.encodePacked("Specimen.escrow", number)),  escrow); 
        lastNumber[msg.sender]  = number;
        if(bytes(eternalStorage.getString(keccak256(abi.encodePacked("pubkey", msg.sender)))).length == 0){
            eternalStorage.setString(keccak256(abi.encodePacked("pubkey", msg.sender)),  pubKey); 
        }        
        emit NewSpecimen(labAccount, serviceCode);
    }

    function getLastNumber() public view returns(string memory){
        return lastNumber[msg.sender];
    }

    function specimenCount() public view returns(uint){
        return specimen.specimenCount(msg.sender);
    }

    function specimenByNumber(string memory _number) public view returns(
        string memory number, address owner, address labAccount, string memory serviceCode, 
        uint timestamp, string memory status, string memory pubkey){  
        (number, owner, labAccount, serviceCode, timestamp, status)  =  specimen.specimenByNumber(_number);
        pubkey = eternalStorage.getString(keccak256(abi.encodePacked("pubkey", owner)));
        return (number, owner, labAccount, serviceCode, timestamp, status, pubkey);
    }

    function specimenByIndex(uint index) public view returns(
        string memory number,address owner, address labAccount, string memory serviceCode, 
        uint timestamp, string memory status, string memory pubkey){        
        string memory number =  eternalStorage.getString(keccak256(abi.encodePacked("Specimen",msg.sender, index )));   
        return specimenByNumber(number);
    }

    function getEscrow(string memory number) public view returns(address){
        return eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number))); 
    }

    function sendSpecimen(string memory number, string memory remark) public {        
        specimenTracking.sendSpecimen(number, remark);
    }

    function receiveSpecimen(string memory number, string memory remark) public {
        specimenTracking.receiveSpecimen(number, remark);
    }

    function rejectSpecimen(string memory number, string memory remark) public {
        specimenTracking.rejectSpecimen(number, remark);
    }

    function analysisSucces(string memory number, string memory file, string memory remark) public {
        specimenTracking.analysisSucces(number, file, remark);
        getEscrowInstance(number).forwardToSeller();
    }

    function getFile(string memory number) public view returns(string memory file){
        return specimenTracking.getFile(number);
    }

    function analysisFail(string memory number, string memory remark) public {
        specimenTracking.analysisFail(number, remark);
        getEscrowInstance(number).refundToBuyer();
    }

    function escrowBalance(string memory number) internal view returns(uint){
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

    function getEscrowInstance(string memory number) internal returns(Escrow){
        address payable escrowWallet = address(uint160(getEscrow(number)));
        Escrow instance = Escrow(escrowWallet);
        return instance;
    }

    function getLabInstance()internal view returns (Lab){
        Lab lab = Lab(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Lab"))));
        return lab;
    }

    


}

//host guitar cool sick provide magic enhance attend faith woman method episode