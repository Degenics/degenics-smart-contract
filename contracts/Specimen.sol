pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./DegenicsLog.sol";
import "./SpecimenTracking.sol";

contract Specimen is Base {

    DegenicsLog degenicsLog;
    SpecimenTracking specimenTracking;

    uint private num = 0;

    modifier onlyDegenicsContract() {
        require(eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))) == msg.sender, "Only registred contract" );
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
    
    constructor(address _storage, address _degenicsLog, address _specimenTracking ) public Base(_storage) {
        degenicsLog = DegenicsLog(_degenicsLog);
        specimenTracking = SpecimenTracking(_specimenTracking);
    }   


    function registerSpecimen(address ownerSpecimen, address labAccount, string memory serviceCode) public onlyDegenicsContract returns(string memory){
        string memory number = getNumber(keccak256(abi.encodePacked("Specimen.number", serviceCode, block.timestamp)));
        num++;
        eternalStorage.setUint(keccak256(abi.encodePacked( "Specimen.registered",number )),block.timestamp );
        eternalStorage.setAddress(keccak256(abi.encodePacked( "Specimen.owner",number )),ownerSpecimen);
        eternalStorage.setAddress(keccak256(abi.encodePacked( "Specimen.lab",number )),labAccount);
        eternalStorage.setString(keccak256(abi.encodePacked( "Specimen.serviceCode",number )),serviceCode);
        specimenTracking.setStatus(number, "New");
        eternalStorage.setString(keccak256(abi.encodePacked("Specimen",ownerSpecimen, 
            eternalStorage.addUint(keccak256(abi.encodePacked("Specimen.count", ownerSpecimen)), 1))), number);
        eternalStorage.setString(keccak256(abi.encodePacked("Specimen",labAccount, 
            eternalStorage.addUint(keccak256(abi.encodePacked("Specimen.count",labAccount)), 1))), number);
        
        degenicsLog.addSpecimenLog(number, "created", "-");
        return number;  
    }

    function specimenCount(address sender) public view onlyDegenicsContract returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("Specimen.count",sender)));
    }

    function specimenByNumber(string memory _number) public view onlyDegenicsContract returns(
        string memory number, address owner, address labAccount, string memory serviceCode, string memory status){      
        status =specimenTracking.getStatus(_number); 
        if(specimenTracking.checkStatus(_number, "New") && specimenTracking.checkPayment(_number)){
            status = "Paid";
        }
        return(
            _number,
            eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.owner",_number ))),
            eternalStorage.getAddress(keccak256(abi.encodePacked( "Specimen.lab",_number ))),
            eternalStorage.getString(keccak256(abi.encodePacked( "Specimen.serviceCode",_number ))),
            status
        );
    }

    function specimenByIndex(address sender, uint index) public view onlyDegenicsContract returns(
         string memory number, address owner, address labAccount, string memory serviceCode, string memory status){        
        
        return specimenByNumber( eternalStorage.getString(keccak256(abi.encodePacked("Specimen",sender, index ))));
    }

    function escrowBalance(string memory number) internal view returns(uint){
        return (eternalStorage.getAddress(keccak256(abi.encodePacked("Specimen.escrow", number)))).balance;
    }

    function getNumber(bytes32 seed) internal returns(string memory){
        string memory res;
        bool repeat = true;
        uint i = 0;
        while(repeat && (i < 255)){
            res = generateNumber(seed);
            if(eternalStorage.getBool(keccak256(abi.encodePacked("Specimen.number", res)))) {
                seed = seed>>1;
                i++;
            } else repeat = false;            
        }
        require(!repeat, "can't generate number");
        eternalStorage.setBool(keccak256(abi.encodePacked("Specimen.number", res)), true);
        return res;
    }

    function generateNumber(bytes32 val) internal view returns(string memory){
        string memory letters = "0123456789ABCDEFGHJKLMNOPQRSTUVXYZ";
        bytes memory alphabet = bytes(letters);
        byte temp = val[31] & 0x1f;
        uint8 len = 12;
        uint8 j = len -1;
        bytes memory result = new bytes(len);
        for(uint i = 0; i < len; i++) {
            result[j] = alphabet[uint8(temp)];
            val = val>>5;
            temp = val[31] & 0x1f;
            j--;
        }
        return string(result);
    }


}

//97J05EE1B531