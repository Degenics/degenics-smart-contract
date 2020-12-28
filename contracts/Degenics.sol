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


    enum SpecimenStatus{ OPEN, PAID, SEND, RECEIVE, TESTED, SUCCESS, FAIL }


    Location location;
    Account account;
    Specimen specimen;


    event NewLab(address account, string name, string country, string city);
    event NewService(address account, string name, string service);
    event NewSpecimen(address labAccount, string Code);

    modifier onlyLab() {
        require(roleHas("lab",msg.sender),
         "Only Lab" );
        _;
    }

    constructor(address _storage, address _account, address _specimen, address _location ) public Base(_storage) {
        location = Location(_location);
        account = Account(_account);
        specimen = Specimen(_specimen);

    }

    function registerLab(address _account, string memory name, 
        string memory country, string memory city) public onlySuperUser{

        require( eternalStorage.getUint(keccak256(abi.encodePacked("lab.index", _account))) ==0, "Already register" );

        account.register(_account, "lab");
        location.register(country, city);

        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.count")), 1);
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.index", _account)), index);

        index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.location",country, city)), 1);
        eternalStorage.setAddress(keccak256(abi.encodePacked("lab.location",country, city, index)), _account);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.name", _account)), name);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.country", _account)), country);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.city", _account)), city);
        emit NewLab(_account, name, country, city);
    }
    
    function registerService(string memory code, string memory serviceName, uint price) public onlyLab{
        require(eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code))) == 0, "Code already register");
        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("lab.service.count", msg.sender)), 1);
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.code", msg.sender, code)), index);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.code", msg.sender, index )), code);
        eternalStorage.setString(keccak256(abi.encodePacked("lab.service.name", msg.sender, code)), serviceName );
        eternalStorage.setUint(keccak256(abi.encodePacked("lab.service.price", msg.sender, code)), price );
        emit NewService(msg.sender, code, serviceName);
    }

    function labCount(string memory country, string memory city) public view returns(uint){
        return  eternalStorage.getUint(keccak256(abi.encodePacked("lab.location",country, city)));
    }

    function labByIndex(string memory _country, string memory _city, uint index) public view returns(address labAccount, string memory name, string memory country, string memory city){
        address account = eternalStorage.getAddress(keccak256(abi.encodePacked("lab.location", _country,_city, index)));
        return labByAccount(account);
    }

    function labByAccount(address _account) public view 
        returns(address labAccount, string memory name, string memory country, string memory city){
           
        name = eternalStorage.getString(keccak256(abi.encodePacked("lab.name", _account)));
        country = eternalStorage.getString(keccak256(abi.encodePacked("lab.country", _account)));
        city = eternalStorage.getString(keccak256(abi.encodePacked("lab.city", _account))); 
        labAccount = _account;   
    }

    function serviceCount(address labAccount) public view returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.count", labAccount)));
    }

    function serviceByIndex(address labAccount, uint index) public view returns(string memory code, string memory serviceName, uint price){
        code = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.code", labAccount, index )));
        serviceName = eternalStorage.getString(keccak256(abi.encodePacked("lab.service.name", labAccount, code)));
        price = eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, code)));
        return(code, serviceName, price);
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


}

//host guitar cool sick provide magic enhance attend faith woman method episode