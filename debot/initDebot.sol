pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "base/Debot.sol";
import "base/Terminal.sol";
import "base/Menu.sol";
import "base/AddressInput.sol";
import "base/Sdk.sol";
import "main.sol";

/*1. Абстрактный контракт дебота. "Дебот инициализация списка"
Содержит в себе методы, связанные с работой со списком покупок в целом. Прежде всего это проверка того, создан ли уже список покупок и все что с этим связано.
Называться у вас методы будут инаце, но в целом это:
setTodoCode, savePublicKey, checkStatus, creditAccount, waitBeforeDeploy, checkIfStatusIs0, deploy */

abstract contract initDebot is Debot{
    function _menu() virtual public;
    function setSummary(Summary sum) virtual public;
    function getSummary(uint32 answerId) virtual public view;

    bytes m_icon;

    TvmCell m_shoppingListCode; // shopingList contract code
    TvmCell m_shoppingListData;
    TvmCell m_shoppingListStateInit;
    address m_address;  // shopingList contract address
    Summary m_stat;        // Statistics of incompleted and completed purchases
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial shopingList contract balance
    
    function setShoppingListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListCode = code;
        m_shoppingListData = data;
        m_shoppingListStateInit = tvm.buildStateInit(m_shoppingListCode, m_shoppingListData);
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a shopping list ...");
            TvmCell deployState = tvm.insertPubkey(m_shoppingListStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your shopping list contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            getSummary(tvm.functionId(setSummary));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(doTransaction),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your shopping contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function doTransaction(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        ITransactable(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatTransaction)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatTransaction(uint32 sdkError, uint32 exitCode) public {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        doTransaction(m_msigAddress);
    }

    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractIsActive), m_address);
    }

    function checkIfContractIsActive(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() private view {
            TvmCell image = tvm.insertPubkey(m_shoppingListStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubKey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }

    function onSuccess() public view {
        getSummary(tvm.functionId(setSummary));
    }
}