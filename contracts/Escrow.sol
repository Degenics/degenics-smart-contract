pragma solidity ^0.5.16;


contract Escrow {

    address owner;
    address buyer;
    address seller;
    address creator;
    address degenics;
    uint amount;

    string status; 

    modifier canExecute(){
        require(msg.sender == creator || tx.origin == owner || msg.sender == degenics, "Only creator or owner");
        _;
    }

    constructor(address _owner, address _degenics, address  _buyer, address  _seller, uint _amount) public {        
        owner = _owner;
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
        creator = msg.sender;
        degenics = _degenics;
        status = "Hold";
    }

    function() external payable {}

    function forwardToSeller() public canExecute  {
        // require(tx.origin == seller, "Only seller");
        address payable _seller = address(uint160(seller));
        _seller.transfer(address(this).balance);
        status = "Forward";
    }

    function refundToBuyer()public canExecute{
        // require(tx.origin == seller, "Only seller");
        address payable _buyer = address(uint160(buyer));
        _buyer.transfer(address(this).balance);
        status = "Refund";
    }


}