pragma solidity  ^0.5.16;

/*
 * @title TODO Add comments.
 *
 * @author Douglas Molina <doug.molina@bitbrackets.io>
 * @author Guillermo Salazar <guillermo@bitbrackets.io>
 * @author Daniel Tutila <daniel@bitbrackets.io>
 */
interface EternalStorageInterface {
    /// @dev Eternal Storage Interface 

    // Modifiers
    modifier onlyLatestContract() {_;}
    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string memory);
    function getBytes(bytes32 _key) external view returns (bytes memory);
    function getBytes32(bytes32 _key) external view returns (bytes32);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
    function getInt8Array(bytes32 _key) external view returns (uint8[100] memory);
    // Setters
    function setAddress(bytes32 _key, address _value)  external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string calldata _value)  external;
    function setBytes(bytes32 _key, bytes calldata _value)  external;
    function setBytes32(bytes32 _key, bytes32 _value)  external;
    function setBool(bytes32 _key, bool _value)  external;
    function setInt(bytes32 _key, int _value)  external;
    function setInt8Array(bytes32 _key, uint8[100] calldata _values)  external;
    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBytes32(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;
    function deleteInt8Array(bytes32 _key) external;

    //ext math operation 
    function addUint(bytes32 _key, uint _value) external returns(uint);
    function subUint(bytes32 _key, uint _value) external returns(uint);
}

