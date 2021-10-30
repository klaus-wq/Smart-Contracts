
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "warUnit.sol";

contract archer is warUnit {

    constructor(baseStation bs) warUnit(bs) public {}
    
    //получить силу атаки
    function getPowerOfAttack() internal override {
        tvm.accept();
        powerOfAttack = 5;
    }

    //получить силу защиты
    function getPowerOfProtection() internal override {
        tvm.accept();
        powerOfProtection = 5;
    }
}
