pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'main.sol';

contract Todo {
    /*
     * ERROR CODES
     * 102 - purchase not found
     */

    //- контроль за правами доступа (onlyOwner)
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;

    mapping(uint32 => Buy) m_buyes;

    uint256 m_ownerPubkey;

    //- конструктор
    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    //- список покупок-статистика о покупках
    function getSummary() public view returns (Summary sum) {
        uint32 countPaid;
        uint32 countUnpaid;

        for((, Buy item) : m_buyes) {
            if  (item.isBuy) {
                countPaid ++;
            } else {
                countUnpaid ++;
            }
        }
        sum = Summary( countPaid, countUnpaid, countPaid + countUnpaid);
    }

    //- добавление покупки в список (параметры: название продукта, количество)
    function addBuyToList(string title, uint32 count) public onlyOwner {
        tvm.accept();
        m_count++;
        m_buyes[m_count] = Buy(m_count, title, count, now, false, 0);
    }

    //-- удаление покупки из списка
    function deleteBuyFromList(uint32 id) public onlyOwner {
        require(m_buyes.exists(id), 102);
        tvm.accept();
        delete m_buyes[id];
    }

    //- купить [помечает, чты вы купили; купить обратно, то есть сбросить флаг покупки  не надо делать]. параметры: (ID, цена)*/
    function buy(uint32 id, uint32 price) public onlyOwner {
        optional(Buy) buy1 = m_buyes.fetch(id);
        require(buy1.hasValue(), 102);
        tvm.accept();
        Buy thisBuy = buy1.get();
        thisBuy.isBuy = true;
        thisBuy.price = price;
        m_buyes[id] = thisBuy;
    }

    //вывести данные о всех покупках
    function getBuyes() public view returns (Buy[] buyes) {
        string title;
        uint32 count;
        uint32 timestamp;
        bool isPurchase;
        uint32 price;

        for((uint32 id, Buy buy1) : m_buyes) {
            title = buy1.title;
            count = buy1.count;
            timestamp = buy1.timestamp;
            isPurchase = buy1.isBuy;
            price = buy1.price;
            buyes.push(Buy(id, title, count, timestamp, isPurchase, price));
       }
    }
}