pragma solidity ^0.5.16;

import "./common/Base.sol";
import "./Escrow.sol";


contract EscrowFactory is Base {

    constructor(address _storage ) public Base(_storage) {
    
    }

    function createEscrow(address buyer, address seller, uint amount) public returns(address){
        Escrow newEscrow = new Escrow(
            eternalStorage.getAddress(keccak256(abi.encodePacked("owner"))),
            eternalStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Degenics"))),
            buyer,
            seller,
            amount
        );
        return address(newEscrow);
    }



}