
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "gameObject.sol";

contract baseStation is gameObject {
    gameObject[] warUnits;

    //получить силу защиты
    function getPowerOfProtection() internal override {
        tvm.accept();
        powerOfProtection = 10;
    }

    //Добавить военный юнит (добавляет адрес военного юнита в массив или другую структуру данных)
    function addWarUnit(gameObject warUnit) public {
        tvm.accept();
        warUnits.push(warUnit);
    }

    //Убрать военный юнит
    function deleteWarUnit(address addressWarUnit) public {
        tvm.accept();
        uint8 indexToDel = 0;
        for (uint8 i = 0; i < warUnits.length - 1; i++) {
            if (warUnits[i] == addressWarUnit) {
                indexToDel = i;
                break;
            }
        }
        //delete warUnits[addressWarUnit];
        for (uint8 i = indexToDel; i < warUnits.length - 1; i++) {
            warUnits[i] = warUnits[i+1];
        }
        warUnits.pop();
    }

    //обработка гибели [вызов метода самоуничтожения + вызов метода смерти для каждого из военных юнитов базы]
    function dead() internal override {
        tvm.accept();
        if (health <= 0) {
            for (uint8 i = 0; i < warUnits.length; i++) {
                warUnits[i].selfDestruction(attackerAddress);
        }
            selfDestruction(attackerAddress);
        }
    }
}
