pragma solidity ^0.5.16;


import "./common/Base.sol";

contract DegenicsLog is Base {

    modifier onlyDegenicsContract() {
        require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender,
            "Only registred contract" );
        _;
    }

    modifier onlyAllowContract() {
       require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender ||
        eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Specimen"))) == msg.sender ||
        eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "SpecimenTracking"))) == msg.sender, "Only registred contract" );
        _;
    }

    constructor(address _storage ) public Base(_storage) {
        
    }

    function addSpecimenLog(string memory number, string memory logType, string memory log) public onlyAllowContract {
        uint index = eternalStorage.addUint(keccak256(abi.encodePacked( "Specimen.Log.count",number)),1);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.log.type",number, index )), logType);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.log",number, index )), log);
        eternalStorage.setUint(keccak256(abi.encodePacked( "Specimen.log.time",number, index )), block.timestamp);
    }

    function countSpecimenLog(string memory number) public view  returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked( "Specimen.Log.count",number)));
    }

    function specimenLogByIndex(string memory number, uint _index) public view returns(uint index, 
        uint time, string memory logType, string memory log){
        
        index = _index;
        logType = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.log.type",number, index )));
        log = eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.log",number, index )));
        time = eternalStorage.getUint(keccak256(abi.encodePacked( "Specimen.log.time",number, index )));
        return (index, time, logType, log);
    }

}