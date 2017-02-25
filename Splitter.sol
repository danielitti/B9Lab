pragma solidity ^0.4.5;

contract Splitter {
    
    address private pOwner; 
    address private pAlice; 
    address private pBob;   
    address private pCarol; 
   
    function Splitter(address Alice, address Bob, address Carol) payable {
        pOwner = msg.sender;
        // forcing to have 3 distinct accounts + coinbase
        if (Alice == address(0) || Bob == address(0) || Carol == address(0)) throw;
        if (Alice == Bob || Bob == Carol || Carol == Alice) throw; 
        pAlice = Alice;
        pBob   = Bob;
        pCarol = Carol;
    }

    function () payable {}
    
    function getAddress(bytes8 addressOwner) constant returns (address) {
        if (addressOwner == 'Owner') {
            return pOwner;
        }
        if (addressOwner == 'Alice') {
            return pAlice;
        }
        if (addressOwner == 'Bob') {
            return pBob;
        }
        if (addressOwner == 'Carol') {
            return pCarol;
        } else {
            throw;
        }
    }

    function split() payable {
        if (msg.value == 0) throw; 
        if (msg.sender == pAlice) {
            if (!pBob.send(msg.value/2)) throw;   
            if (!pCarol.send(msg.value - msg.value/2)) throw; 
        } 
    }

    function killMe() {
        if (msg.sender == pOwner) {
            suicide(pOwner);
        } else {
            throw;
        }
    }

}