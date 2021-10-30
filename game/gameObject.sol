pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "intGameObj.sol";

contract gameObject is intGameObj {
    //свойство с начальным количеством жизней (например, 5)
    int health = 5;
    //сила защиты
    int powerOfProtection;
    address attackerAddress;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        getPowerOfProtection();
        tvm.accept();
    }

    //получить силу защиты
    function getPowerOfProtection() virtual internal {
        tvm.accept();
        powerOfProtection = 10;
    }

    //принять атаку [адрес того, кто атаковал можно получить из msg] external
    function takeAttack(int attack) external override {
        tvm.accept();
        if ((powerOfProtection - attack) < 0) {
            health += (powerOfProtection - attack);
        } else {
            health -= (powerOfProtection - attack);
        }
        attackerAddress = msg.sender;
        dead();
    }

    //проверить, убит ли объект (private)
    function isDead() private returns(bool) {
        tvm.accept();
        if (health > 0) return false;
        else return true;
    }

    //обработка гибели [вызов метода самоуничтожения (сл в списке)]
    function dead() virtual internal {
        tvm.accept();
        if (isDead()) {
            selfDestruction(attackerAddress);
        }
    }

    //отправка всех денег по адресу и уничтожение
    function selfDestruction(address attackerAddress) public {
		tvm.accept();
        attackerAddress.transfer(0, false, 160);
    }

    //просмотр количества единиц здоровья
    function getHealth() public returns(int) {
        tvm.accept();
        return health;
    }
}
