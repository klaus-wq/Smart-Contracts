pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "baseStation.sol";

contract warUnit is gameObject {
    baseStation addressBaseStation;
    int powerOfAttack;

    //конструктор принимает "Базовая станция" и вызывает метод "Базовой Станции" "Добавить военный юнит" а у себя сохраняет адрес "Базовой станции"
    constructor(baseStation addrBS) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        addressBaseStation = addrBS;
        addrBS.addWarUnit(this);
        getPowerOfProtection();
        getPowerOfAttack();
        tvm.accept();
    }

    //атаковать (принимает ИИО [его адрес])
    function attack(intGameObj intGameObjAddr) public {
        tvm.accept();
        intGameObjAddr.takeAttack(powerOfAttack);
    }

    //получить силу атаки
    function getPowerOfAttack() virtual internal {
        tvm.accept();
        powerOfAttack = 10;
    }

    //получить силу защиты
    function getPowerOfProtection() virtual internal override {
        tvm.accept();
        powerOfProtection = 20;
    }

    //обработка гибели [вызов метода самоуничтожения + убрать военный юнит из базовой станции]
    function dead() internal override {
        tvm.accept();
        if (health <= 0) {
            addressBaseStation.deleteWarUnit(this);
            selfDestruction(attackerAddress);
        }
    }

    //смерть из-за базы (проверяет, что вызов от родной базовой станции только будет работать) [вызов метода самоуничтожения]
    function deadBase() internal {
        tvm.accept();
        selfDestruction(attackerAddress);
    }
}
