pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./DegenicsLog.sol";

contract SpecimenTracking is Base {

    DegenicsLog degenicsLog;
    
    modifier onlyAllowContract() {
        require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender ||
                eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Specimen"))) == msg.sender
        , "Only registred contract" );
        _;
    }

    modifier onlyLab(string memory number){
        require(roleHas("lab", tx.origin) && 
            eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number ))) == tx.origin,
            "Only lab");
        _;
    }

    modifier onlySpecimenOwner(string memory number){
        require(eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.owner",number ))) == tx.origin, "Only Owner specimen");
        _;
    }
    
    constructor(address _storage, address _degenicsLog ) public Base(_storage) {
        degenicsLog = DegenicsLog(_degenicsLog);
    }

    function escrowBalance(string memory number) internal view returns(uint){
        return (eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number)))).balance;
    }

    function sendSpecimen(string memory number, string memory remark) public onlyAllowContract onlySpecimenOwner(number) {
       require(checkStatus(number, "New") && 
            checkPayment(number), "Only paid test");  
        setStatus(number, "Sending");
        degenicsLog.addSpecimenLog(number, "send", remark);
    }

    function receiveSpecimen(string memory number, string memory remark) public onlyAllowContract onlyLab(number) {
        require(checkStatus(number, "Sending") || (checkStatus(number, "New") && checkPayment(number) ) , "Only sending specimen" );
        setStatus(number, "Received");
        degenicsLog.addSpecimenLog(number, "receive", remark);
    }

    function rejectSpecimen(string memory number, string memory remark) public onlyAllowContract onlyLab(number) {
        require(checkStatus(number, "Sending") || (checkStatus(number, "New") &&   checkPayment(number)) , "Only sending specimen" );
        setStatus(number, "Reject");
        degenicsLog.addSpecimenLog(number, "reject", remark);
    }

    function analysisSucces(string memory number, string memory file, string memory remark) public onlyAllowContract onlyLab(number) {
        require(checkStatus(number, "Received"), "Only Received specimen" );
        setStatus(number, "Succes");
        degenicsLog.addSpecimenLog(number, "succes", remark);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.file",number)), file);
    }

    function analysisFail(string memory number, string memory remark) public onlyAllowContract onlyLab(number) {
        require(compareString(getStatus(number), "Received"), "Only Received specimen" );
        degenicsLog.addSpecimenLog(number, "fail", remark);
    }

    function checkPrice(string memory number) internal view returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("lab.service.price", 
            eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number ))), 
            eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.serviceCode",number )))
        )));
    }

    function logByIndex(string memory number, uint _index)public onlyAllowContract returns(uint index, uint time, 
        string memory logType, string memory log){
        return degenicsLog.specimenLogByIndex(number, _index);
    }

    function setStatus(string memory number, string memory status) public  onlyAllowContract{
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.status",number )), status);
    }

    function getStatus(string memory number) public view onlyAllowContract returns(string memory){
        return eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.status",number )));       
    }

    function checkStatus(string memory number, string memory status) public view onlyAllowContract returns(bool){
        return compareString(getStatus(number), status);
    }

    function getFile(string memory number) public view onlyAllowContract  returns(string memory file){
        require(eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",number ))) == tx.origin || 
    eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.owner",number ))) == tx.origin, "Only owner and lab");  
        return eternalStorage.getString(keccak256(abi.encodePacked("Specimen.file",number)));
    }
    
    function checkPayment(string memory number) public view onlyAllowContract returns(bool){
        return escrowBalance(number) >=  checkPrice(number);
        // return true;
    }
}