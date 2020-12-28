// pragma solidity ^0.4.14;
pragma solidity ^0.5.16;

import "../interface/EternalStorageInterface.sol";

/*
 * @title Base settings / modifiers for BitBrackets Contracts.
 *
 * @author Douglas Molina <doug.molina@bitbrackets.io>
 * @author Guillermo Salazar <guillermo@bitbrackets.io>
 * @author Daniel Tutila <daniel@bitbrackets.io>
 */
contract Base {

    EternalStorageInterface public eternalStorage = EternalStorageInterface(0);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        roleCheck("owner", msg.sender);
        _;
    }

    /**
    * @dev Modifier to scope access to admins
    */
    modifier onlyAdmin() {
        // roleCheck("admin", msg.sender);
        require(roleHas("admin",msg.sender),
         "Only Admin" );
        _;
    }

    /**
    * @dev Modifier to scope access to admins
    */
    modifier onlySuperUser() {
        require(
            roleHas("owner", msg.sender) == true ||
            roleHas("admin", msg.sender) == true,
            "Only super User"
        );
        _;
    }

    /**
    * @dev Reverts if the address doesn't have this role
    */
    modifier onlyRole(string memory _role) {
        roleCheck(_role, msg.sender);
        _;
    }

    modifier onlyAllowedContract() {
        require(eternalStorage.getBool(keccak256(abi.encodePacked("contract.valid", msg.sender))), "Only registred contract" );
        _;
    }

    
    /*** Constructor **********/
   
    /// @dev Set the main Storage address
    constructor(address _storageAddress) public {
        // Update the contract address
        eternalStorage = EternalStorageInterface(_storageAddress);
    }

    /*** Role Utilities */

    /**
    * @dev Check if an address has this role
    * @return bool
    */
    function roleHas(string memory _role, address _address) internal view returns (bool) {
        return eternalStorage.getBool(keccak256(abi.encodePacked("access.role", _role, _address)));
    }

    
     /**
    * @dev Check if an address has this role, reverts if it doesn't
    */
    function roleCheck(string memory _role, address _address) internal view {
        require(roleHas(_role, _address) == true, "Not have acces");
    }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    function compareString(string memory _string1, string memory _string2) internal pure returns(bool) {
        if(bytes(_string1).length != bytes(_string2).length) {
            return false;
        } else {
            return keccak256(abi.encodePacked(_string1)) == keccak256(abi.encodePacked(_string2));
        }
    }
}