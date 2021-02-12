pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";


contract Account is Base {

    constructor(address _storage ) public Base(_storage) {
    
    }

    function register(address account, string memory role) public {
        require(roleHas("owner", msg.sender) ||  
        roleHas("admin", msg.sender) || 
        eternalStorage.getBool(keccak256(abi.encodePacked("contract.valid", msg.sender))), "Only super user or contract" );

        require( eternalStorage.getUint(keccak256(abi.encodePacked("account.index", account))) == 0, "Already register" );    

        uint index = eternalStorage.addUint(keccak256(abi.encodePacked("account.index")),1);
        eternalStorage.setAddress(keccak256(abi.encodePacked("account.address", index)), account);
        eternalStorage.setUint(keccak256(abi.encodePacked("account.index", account)), index);
        eternalStorage.setString(keccak256(abi.encodePacked("account.role",account)), role );
        eternalStorage.setBool(keccak256(abi.encodePacked("access.role", role, account)), true);
        eternalStorage.setBool(keccak256(abi.encodePacked("account", account)), true);
    }

    function myRole()public view returns(string memory role){
        role = eternalStorage.getString(keccak256(abi.encodePacked("account.role",msg.sender)));
        if(eternalStorage.getBool(keccak256(abi.encodePacked("access.role", role, msg.sender)))) return role;
        return "";
    }

    function getPublicKey(address _address) public view returns(string memory){
        return eternalStorage.getString(keccak256(abi.encodePacked("pubkey",_address)));
    }

}