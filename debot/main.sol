pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

/*Структура:
"Покупка"
- идентификатор/номер
- название
- количество (сколько надо купить)
- когда заведена
- флаг, что куплена (при заведении в список всегда false)
- цена, за которую купили [за все единиицы сразу] (при заведении в список всегда 0)*/
struct Buy {
    uint32 id;
    string title;
    uint32 count;
    uint32 timestamp;
    bool isBuy;
    uint32 price;
}

/*Структура "Саммари покупок"
- сколько предметов в списке "оплачено"
- сколько предметов в списке "не оплачено"
- на какую сумму всего было оплачено
Если список содержит "Молоко, кол-во 2", "сметана, кол-во 3", то в статистике это будет "5" */
struct Summary {
    uint32 countPaid;
    uint32 countUnpaid;
    uint32 totalPrice;
}

//интерфейс "Список покупок"
interface IShopingList {   
    function getSummary() external returns (Summary);
    function addBuyToList(string title, uint32 count) external;
    function deleteBuyFromList(uint32 id) external;
    function buy(uint32 id, uint32 price) external;
    function getBuyes() external returns (Buy[] buyes);
}

interface ITransactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
}

//абстрактный контракт
abstract contract HasConstructorWithPubKey {
    constructor(uint256 pubkey) public {}
}