// pragma solidity ^0.4.14;
pragma solidity ^0.5.16;

/*
 * @title Eternal Storage for Bit Brackets Contracts inspired by the awesome RocketPool project and Eternal Storage implementations.
 *
 * @author Douglas Molina <doug.molina@bitbrackets.io>
 * @author Guillermo Salazar <guillermo@bitbrackets.io>
 * @author Daniel Tutila <daniel@bitbrackets.io>
 */

import "./SafeMath.sol";

contract EternalStorage {

    using SafeMath for uint256;

    mapping(bytes32 => string)       private stringStorage;
    mapping(bytes32 => address)      private addressStorage;
    mapping(bytes32 => bytes)        private bytesStorage;
    mapping(bytes32 => bool)         private boolStorage;
    mapping(bytes32 => int256)       private intStorage;
    mapping(bytes32 => uint)         private uIntStorage;
    mapping(bytes32 => uint8[100])   private int8ArrayStorage;
    mapping(bytes32 => bytes32)      private bytes32Storage;

    address private _owner;


    /*** Modifiers ************/

    // @dev Only allow access from the Bit Brackets contracts
    modifier onlyAllowedContract() {
        // The owner and other contracts are only allowed to set the storage upon deployment to register the initial contracts/settings, afterwards their direct access is disabled
        if (boolStorage[keccak256("contract.storage.initialised")] == true) {
            // Make sure the access is permitted to only contracts in our control
            require(boolStorage[keccak256(abi.encodePacked("contract.valid", msg.sender))], "Only registered contract");
        } else {
            require(_owner ==  tx.origin || boolStorage[keccak256(abi.encodePacked("contract.valid", msg.sender))] == true, "Only registered contract" );
        }
        _;
    }


    /// @dev constructor
    constructor() public {
        // Set the main owner upon deployment
        // TODO implement ownable using access.role to allow admins
        boolStorage[keccak256(abi.encodePacked("access.role", "owner", msg.sender))] = true;
        boolStorage[keccak256(abi.encodePacked("account", msg.sender))] = true;
        uint index = 1;
        uIntStorage[keccak256(abi.encodePacked("User.index"))] = index;
        addressStorage[keccak256(abi.encodePacked("User.address", index))] = msg.sender;
        uIntStorage[keccak256(abi.encodePacked("User.index", msg.sender))] = index;
        stringStorage[keccak256(abi.encodePacked("User.role",msg.sender))] = "owner";

    }

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    /// @param _key The key for the record
    function getString(bytes32 _key) external view returns (string memory) {
        return stringStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes(bytes32 _key) external view returns (bytes memory) {
        return bytesStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes32(bytes32 _key) external view returns (bytes32) {
        return bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    /// @param _key The key for the record
    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }


    /// @param _key The key for the record
    function getInt8Array(bytes32 _key) external view returns (uint8[100] memory) {
        return int8ArrayStorage[_key];
    }

    /**** Set Methods ***********/

    /// @param _key The key for the record
    function setAddress(bytes32 _key, address _value) external onlyAllowedContract {
        addressStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint(bytes32 _key, uint _value) external onlyAllowedContract {
        uIntStorage[_key] = _value;
    }

    

    /// @param _key The key for the record
    function setString(bytes32 _key, string calldata _value) external onlyAllowedContract {
        stringStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes(bytes32 _key, bytes calldata _value) external onlyAllowedContract {
        bytesStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes32(bytes32 _key, bytes32 _value) external onlyAllowedContract {
        bytes32Storage[_key] = _value;
    }
    
    /// @param _key The key for the record
    function setBool(bytes32 _key, bool _value) external onlyAllowedContract {
        boolStorage[_key] = _value;
    }
    
    /// @param _key The key for the record
    function setInt(bytes32 _key, int _value) external onlyAllowedContract {
        intStorage[_key] = _value;
    }
    /// @param _key The key for the record
    /// @param _values Array of Values
    function setInt8Array(bytes32 _key, uint8[100] calldata _values) external onlyAllowedContract {
        int8ArrayStorage[_key] = _values;
    }

    /**** Delete Methods ***********/
    
    /// @param _key The key for the record
    function deleteAddress(bytes32 _key) external onlyAllowedContract {
        delete addressStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint(bytes32 _key) external onlyAllowedContract {
        delete uIntStorage[_key];
    }

     
    /// @param _key The key for the record
    function deleteString(bytes32 _key) external onlyAllowedContract {
        delete stringStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes(bytes32 _key) external onlyAllowedContract {
        delete bytesStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes32(bytes32 _key) external onlyAllowedContract {
        delete bytes32Storage[_key];
    }
    
    /// @param _key The key for the record
    function deleteBool(bytes32 _key) external onlyAllowedContract {
        delete boolStorage[_key];
    }
    
    /// @param _key The key for the record
    function deleteInt(bytes32 _key) external onlyAllowedContract {
        delete intStorage[_key];
    }

    /// @param _key The key for the record
    function deleteInt8Array(bytes32 _key)  external onlyAllowedContract {
        delete int8ArrayStorage[_key];
    }

    //math operation 

    function addUint(bytes32 _key, uint _value) external onlyAllowedContract returns(uint) {
        uIntStorage[_key] = uIntStorage[_key].add(_value);
        return uIntStorage[_key];
    }

    function subUint(bytes32 _key, uint _value) external onlyAllowedContract returns(uint)   {
        uIntStorage[_key] = uIntStorage[_key].sub(_value);
        return uIntStorage[_key];
    }

    function registryContract(string calldata _name, address _address) external   {
        require(!boolStorage[keccak256(abi.encodePacked("contract.storage.initialised"))] || 
            msg.sender == _owner, "Already initialised");
        require(boolStorage[keccak256(abi.encodePacked("access.role", "owner", msg.sender))], "Only owner can execute");
        address oldAddress = addressStorage[keccak256(abi.encodePacked("contract.name", _name))];
        boolStorage[keccak256(abi.encodePacked("contract.valid", _address))] = true;
        addressStorage[keccak256(abi.encodePacked("contract.address", _name))] = _address;
        stringStorage[keccak256(abi.encodePacked("contract.name", _address))] = _name;
        if(oldAddress!= address(0)){
            boolStorage[keccak256(abi.encodePacked("contract.valid", oldAddress))] = false;
        }
    }

    function changeOwner(address _newOwner) public {
        require(msg.sender == _owner, "Only owner");        
        require(boolStorage[keccak256(abi.encodePacked("access.role", "owner", _newOwner))] != true);
        require(boolStorage[keccak256(abi.encodePacked("account", _newOwner))] != true);
        boolStorage[keccak256(abi.encodePacked("access.role", "owner", _newOwner))] = true;
        boolStorage[keccak256(abi.encodePacked("account", _newOwner))] = true;
        boolStorage[keccak256(abi.encodePacked("access.role", "owner", _owner))] =false;
        boolStorage[keccak256(abi.encodePacked("account", _owner))] = false;
        _owner = _newOwner;
    }

    function finishInit() public {
        require(msg.sender == _owner);
        boolStorage[keccak256("contract.storage.initialised")] = true;
    }
}