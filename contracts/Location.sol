pragma solidity ^0.5.16;


import "./common/Base.sol";
import "./common/SafeMath.sol";
import "./common/Address.sol";


contract Location is Base {

    constructor(address _storage ) public Base(_storage) {
    
    }

    function register(string memory country, string memory city) public onlyAllowedContract{
        uint index =  eternalStorage.getUint(keccak256(abi.encodePacked("country", country)));
        if(index == 0) {
            index = eternalStorage.addUint(keccak256("country.count"), 1);
            eternalStorage.setUint(keccak256(abi.encodePacked("country", country)), index);
            eternalStorage.setString(keccak256(abi.encodePacked("country", index)), country);
        }
        index = eternalStorage.getUint(keccak256(abi.encodePacked("city", country, city )));
        if(index == 0) {
            index = eternalStorage.addUint(keccak256(abi.encodePacked("city.count", country)), 1);
            eternalStorage.setUint(keccak256(abi.encodePacked("city", country, city)), index);
            eternalStorage.setString(keccak256(abi.encodePacked("city", country, index)), city);
        }
    }

    function countCountry() public view returns(uint){
        return eternalStorage.getUint(keccak256("country.count"));
    }

    function countryByIndex(uint index) public view returns(string memory){
        return eternalStorage.getString(keccak256(abi.encodePacked("country", index)));
    }

    function countCity(string memory country) public view returns(uint){
        return eternalStorage.getUint(keccak256(abi.encodePacked("city.count", country)));
    }

    function cityByIndex(string memory country, uint index) public view returns(string memory){
        return eternalStorage.getString(keccak256(abi.encodePacked("city", country, index)));
    }

}