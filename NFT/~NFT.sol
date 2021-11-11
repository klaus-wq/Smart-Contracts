pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract NFT {

    struct Book {
        string title;
        string firstNameOfAuthor;
        string LastNameOfAuthor;
        uint year;
        string language;
    }

    Book[] booksArr;
    mapping (uint => uint) bookToOwner;
    mapping (uint=>uint) shop;

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}

    modifier checkOwnership(uint tokenId){
        require(msg.pubkey() == bookToOwner[tokenId], 101);
        _;
    }

    //в методе создания токена должна быть проверка на уникальность имени. Выпускать "одноименные" токены должно быть нельзя
    function createToken(string title, string firstNameOfAuthor, string LastNameOfAuthor, uint year, string language) public checkOwnerAndAccept {
        uint key = booksArr.length;
        for(uint i = 0; i < booksArr.length; i++){
            require(booksArr[i].title != title, 102);
        }
        booksArr.push(Book(title, firstNameOfAuthor, LastNameOfAuthor, year, language));
        bookToOwner[key] = msg.pubkey();
    } 

    //просмотр свойств книги
    function getTokenInfo(uint tokenId) public view returns(Book) {
        return booksArr[tokenId];
    }

    //просмотр владельца книги
    function getTokenOwner (uint tokenId) public view returns(uint){
        return bookToOwner[tokenId];
    }

    //должна быть возвожность "выставить токен на продажу", то есть указать стоимость по которой токен продается. Должно быть доступно толкьо владельцу
    function sendToTheShop(uint tokenId, uint price) public checkOwnerAndAccept checkOwnership(tokenId){       
        require(!shop.exists(tokenId), 103);    
        shop[tokenId]=price;
    }
    //просмотр выставленных на продажу книг
    function showShop() public returns(mapping(uint => uint)) {
        return shop;        
    }
}
