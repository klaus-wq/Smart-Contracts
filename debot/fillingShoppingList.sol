pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "initDebot.sol";

/*2.1. Контракт "Дебот наполнение Списка Покупок"
Меню содержит:
Добавление продукта (обратите внимание, что вам несколько раз надо запрашивать у пользователя данные. Сперва про название, затем про количество.
Вывод списка покупок
Удаление покупки */

abstract contract fillingShoppingList is initDebot {

    string title1;
    uint32 count1;

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    function _menu() override public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (paid/unpaid/total) purchases",
                    m_stat.countPaid,
                    m_stat.countUnpaid,
                    m_stat.totalCount
            ),
            sep,
            [
                MenuItem("Add new purchase","",tvm.functionId(addBuyToList)),
                MenuItem("Show shopping list","",tvm.functionId(showBuyes)),
                MenuItem("Delete purchase","",tvm.functionId(deleteBuyFromList))
            ]
        );
    }
    
    function addBuyToList(string title) public {
        title1 = title;
        Terminal.input(tvm.functionId(addBuyToList_), "Input title of the product:", false);
    }

    function addBuyToList_(uint32 count) public  {
        count1 = count;
        Terminal.input(tvm.functionId(addBuyToList__), "Input count you want to buy:", false);
    }

    function addBuyToList__(string value) public view {
        optional(uint256) pubkey = 0;
        IShopingList(m_address).addBuyToList{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(title1, count1);
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }
    
    function showBuyes(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShopingList(m_address).getBuyes{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showBuyes_),
            onErrorId: 0
        }();
    }

    function showBuyes_( Buy[] buyes ) public {
        uint32 i;
        if (buyes.length > 0 ) {
            Terminal.print(0, "Your shopping list:");
            for (i = 0; i < buyes.length; i++) {
                Buy buy = buyes[i];
                string completed;
                if (buy.isBuy) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" count: {}", buy.id, completed, buy.title, buy.count));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function deleteBuyFromList(uint32 index) public {
        index = index;
        if (m_stat.totalCount > 0) {
            Terminal.input(tvm.functionId(deleteBuyFromList_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, your shopping list is empty");
            _menu();
        }
    }

    function deleteBuyFromList_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopingList(m_address).deleteBuyFromList{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }

    function setSummary(Summary sum) public override {
        m_stat = sum;
        _menu();
    }

    function getSummary(uint32 answerId) public override view {
        optional(uint256) none;
        IShopingList(m_address).getSummary{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }
}