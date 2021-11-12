pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "main.sol";

contract shoppingList is IShopingList{
    /*
     * ERROR CODES
     * 102 - purchase not found
     */

    //- контроль за правами доступа (onlyOwner)
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101, "onlyOwner()");
        _;
    }

    uint32 buy_id;

    mapping(uint32 => Buy) m_buyes;

    uint256 m_ownerPubkey;

    //- конструктор
    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    //- список покупок-статистика о покупках
    function getSummary() public override returns (Summary sum) {

        for((uint32 id, Buy buy1) : m_buyes) {
            if  (buy1.isBuy) {
                sum.countPaid ++;
                sum.totalPrice+=buy1.price;
            } else {
                sum.countUnpaid ++;
            }
        }
        return sum;
    }

    //- добавление покупки в список (параметры: название продукта, количество)
    function addBuyToList(string title, uint32 count) public override onlyOwner {
        tvm.accept();
        buy_id++;
        m_buyes[buy_id] = Buy(buy_id, title, count, now, false, 0);
    }

    //-- удаление покупки из списка
    function deleteBuyFromList(uint32 id) public override onlyOwner {
        require(m_buyes.exists(id), 102, "Id did not found");
        tvm.accept();
        delete m_buyes[id];
    }

    //- купить [помечает, чты вы купили; купить обратно, то есть сбросить флаг покупки  не надо делать]. параметры: (ID, цена)*/
    function buy(uint32 id, uint32 price) public override onlyOwner {
        optional(Buy) buy1 = m_buyes.fetch(id);
        require(buy1.hasValue(), 102);
        tvm.accept();
        Buy thisBuy = buy1.get();
        thisBuy.isBuy = true;
        thisBuy.price = price;
        m_buyes[id] = thisBuy;
    }

    //вывести данные о всех покупках
    function getBuyes() public override returns (Buy[] buyes) {
        string title;
        uint32 count;
        uint32 timestamp;
        bool isBuy;
        uint32 price;

        for((uint32 id, Buy buy1) : m_buyes) {
            title = buy1.title;
            count = buy1.count;
            timestamp = buy1.timestamp;
            isBuy = buy1.isBuy;
            price = buy1.price;
            buyes.push(Buy(id, title, count, timestamp, isBuy, price));
       }
    }
}