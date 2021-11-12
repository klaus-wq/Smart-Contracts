Рабочие версии:
Первый дебот - https://web.ton.surf/debot?address=0%3Af7c0fdd8c69001a89fda217254c372401225f7e2adbca9edc804c13f626deb2c&net=devnet&restart=true

Второй дебот - https://web.ton.surf/debot?address=0%3A4aec4a81529fd6d6775417375f426f52a38501586d072f03c6eb5da77b880a78&net=devnet&restart=true

-------------------------------------------------------------------------------------

    tondev sol compile shoppingList.sol
    tonos-cli decode stateinit shoppingList.tvc --tvc
    
сохранить shoppingList.decode.json

    tondev sol compile fillingShoppingList.sol
    tonos-cli genaddr fillingShoppingList.tvc fillingShoppingList.abi.json --genkey fillingShoppingList.keys.json > log.log
    
Заполнить файл params.json
В моем случае:
{
    "dest": "0:f7c0fdd8c69001a89fda217254c372401225f7e2adbca9edc804c13f626deb2c",
    "amount": 10000000000
}

Закинуть денег
https://net.ton.dev - EXTRATON

    tonos-cli --url http://127.0.0.1 call --abi base/local_giver.abi.json 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams params.json

Задеплоить

    tonos-cli --url http://net.ton.dev deploy fillingShoppingList.tvc "{}" --sign fillingShoppingList.keys.json --abi fillingShoppingList.abi.json
    tonos-cli --url http://127.0.0.1 deploy fillingShoppingList.tvc "{}" --sign fillingShoppingList.keys.json --abi fillingShoppingList.abi.json
    bash
    cat fillingShoppingList.abi.json | xxd -p -c 20000
    exit
    
Записать dabi.json - в моем случае:
    {
        "dabi": "7b0d0a0........d0a7d0d0a"
    }

Установить dabi

    tonos-cli --url http://net.ton.dev call 0:f7c0fdd8c69001a89fda217254c372401225f7e2adbca9edc804c13f626deb2c setABI dabi.json --sign fillingShoppingList.keys.json --abi fillingShoppingList.abi.json
    tonos-cli --url http://127.0.0.1 call 0:f93b245d81c1c4832c49d2fe2ab8cf6af3363359b7beb9fe9819f0546e63000e setABI dabi.json --sign fillingShoppingList.keys.json --abi fillingShoppingList.abi.json

вызвать

    tonos-cli --url http://127.0.0.1 run --abi fillingShoppingList.abi.json 0:f93b245d81c1c4832c49d2fe2ab8cf6af3363359b7beb9fe9819f0546e63000e getDebotInfo "{}"
    
предварительно сформировать shoppingList.decode.json

    tonos-cli --url http://net.ton.dev call --abi fillingShoppingList.abi.json --sign fillingShoppingList.keys.json 0:f7c0fdd8c69001a89fda217254c372401225f7e2adbca9edc804c13f626deb2c setShoppingListCode shoppingList.decode.json
    tonos-cli --url http://127.0.0.1 call --abi fillingShoppingList.abi.json --sign fillingShoppingList.keys.json 0:f93b245d81c1c4832c49d2fe2ab8cf6af3363359b7beb9fe9819f0546e63000e setShoppingListCode shoppingList.decode.json

Вызываем дебота
https://web.ton.surf/debot?address=0%3Af7c0fdd8c69001a89fda217254c372401225f7e2adbca9edc804c13f626deb2c&net=devnet&restart=true

    tonos-cli --url http://127.0.0.1 debot fetch 0:a6c61ab1033458b408bb477607dfd5433f09328a61e846882b96c6351830efbf

-------------------------------------------------------------------------------------

    tondev sol compile walkingInTheShop.sol
    tonos-cli genaddr walkingInTheShop.tvc walkingInTheShop.abi.json --genkey walkingInTheShop.keys.json > log1.log
    
params1

    tonos-cli --url http://net.ton.dev deploy walkingInTheShop.tvc "{}" --sign walkingInTheShop.keys.json --abi fillingShoppingList.abi.json
    
dabi1

    bash
    cat walkingInTheShop.abi.json | xxd -p -c 20000
    exit
    tonos-cli --url http://net.ton.dev call 0:4aec4a81529fd6d6775417375f426f52a38501586d072f03c6eb5da77b880a78 setABI dabi1.json --sign walkingInTheShop.keys.json --abi walkingInTheShop.abi.json
    tonos-cli --url http://net.ton.dev call --abi walkingInTheShop.abi.json --sign walkingInTheShop.keys.json 0:4aec4a81529fd6d6775417375f426f52a38501586d072f03c6eb5da77b880a78 setShoppingListCode shoppingList.decode.json
    
https://web.ton.surf/debot?address=0%3A4aec4a81529fd6d6775417375f426f52a38501586d072f03c6eb5da77b880a78&net=devnet&restart=true
