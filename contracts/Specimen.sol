pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";

contract Specimen is Base {

     modifier onlyDegenicsContract() {
        require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender, "Only registred contract" );
        _;
    }

    modifier onlySpecimenOwner(bytes32 number){
        require(eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.owner",number ))) == tx.origin, "Only specimen owner");
        _;
    }

    modifier onlyLab(bytes32 number){
        require(roleHas("lab", tx.origin), "Only lab");
        require(eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number ))) == tx.origin, "Only Lab");
        _;
    }
    
    constructor(address _storage ) public Base(_storage) {
        
    }


    function registerSpecimen(address ownerSpecimen, address labAccount, string memory serviceCode) public onlyDegenicsContract returns(bytes32){
        bytes32 number = keccak256(abi.encodePacked("Specimen", ownerSpecimen, labAccount, serviceCode, block.timestamp ));
        eternalStorage.setUint(keccak256(abi.encodePacked( "Specimen.registered",number )),block.timestamp );
        eternalStorage.setAddress(keccak256(abi.encodePacked( "Specimen.owner",number )),ownerSpecimen);
        eternalStorage.setAddress(keccak256(abi.encodePacked( "Specimen.lab",number )),labAccount);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.serviceCode",number )),serviceCode);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )),"New");
        
        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("Specimen.count", ownerSpecimen)), 1);
        eternalStorage.setBytes32(keccak256(abi.encodePacked("Specimen",ownerSpecimen, index )), number);
        index = eternalStorage.addUint(keccak256(abi.encodePacked("Specimen.count",labAccount)), 1);
        eternalStorage.setBytes32(keccak256(abi.encodePacked("Specimen",labAccount, index )), number);

        eternalStorage.setBytes32(keccak256(abi.encodePacked("Specimen.lastNumber",ownerSpecimen)), number);
        return number;  
    }

    function specimenCount(address sender) public view onlyDegenicsContract returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("Specimen.count",sender)));
    }

    function specimenByNumber(bytes32 number) public view onlyDegenicsContract returns(
        address owner, address labAccount, string memory serviceCode, string memory status){        
        owner = eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.owner",number )));
        labAccount = eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number )));
        serviceCode = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.serviceCode",number )));
        status = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number ))); 
        if(compareString(status, "New") && 
            escrowBalance(number) >=  eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, serviceCode))) ){
            status = "Paid";
        }
        return(owner, labAccount, serviceCode, status);
    }

    function specimenByIndex(address sender, uint index) public view onlyDegenicsContract returns(
        address owner, address labAccount, string memory serviceCode, string memory status){        
        bytes32 number =  eternalStorage.getBytes32(keccak256(abi.encodePacked("Specimen",sender, index )));   
        return specimenByNumber(number);
    }

    function escrowBalance(bytes32 number) internal view returns(uint){
        address escrow = eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number)));
        return escrow.balance;
    }

    function sendSpecimen(bytes32  number, string memory remark) public onlyDegenicsContract onlySpecimenOwner(number) {
        address labAccount = eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number )));
        string memory serviceCode = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.serviceCode",number )));
        string memory status = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number ))); 
        require(compareString(status, "New") && 
            escrowBalance(number) >=  eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", labAccount, serviceCode))), "Only paid test");
        
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )), "Sending"); 
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.remark",number, "send" )), remark);
    }

    function receiveSpecimen(bytes32  number, string memory remark) public onlyDegenicsContract onlyLab(number) {
        string memory status = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number ))); 
        require(compareString(status, "Sending"), "Only sending specimen" );
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )), "Received");
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.remark",number, "receive" )), remark);
    }

    function analysisSucces(bytes32  number, string memory file, string memory remark) public onlyDegenicsContract onlyLab(number) {
        string memory status = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number ))); 
        require(compareString(status, "Received"), "Only Received specimen" );
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )), "Succes");
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.remark",number, "Succes" )), remark);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.file",number)), file);
    }

    function analysisFail(bytes32  number, string memory remark) public onlyDegenicsContract onlyLab(number) {
        string memory status = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number ))); 
        require(compareString(status, "Received"), "Only Received specimen" );
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )), "Failed");
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.remark",number, "Failed" )), remark);
    }

}