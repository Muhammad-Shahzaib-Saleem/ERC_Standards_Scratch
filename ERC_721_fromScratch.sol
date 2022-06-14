// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    
    function toString(uint256 value) internal pure returns (string memory) {
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

  
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

contract ERC721 {

    using Strings for uint;

    string private _name;
    string private _symbol;
    uint private totalSupply;

    mapping(address=>uint)  balances;
    mapping(uint=>address) owners;
    mapping(uint=>address) tokenApprovals;
    mapping(address=>mapping(address=>bool)) operatorApprovals;

    event Transfer(address,address,uint);
    event ApprovalForAll(address,address,bool);
    event Approval(address,address,uint);

    constructor (string memory name_,string memory symbol_){
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view returns(string memory){
        return _name;
    }


    function symbol() public view returns(string memory){
        return _symbol;
    }


    function exists(uint _tokenId) internal view returns(bool){
        return owners[_tokenId] != address(0);
    }


    function balanceOf(address _owner) public view returns(uint){
        require(_owner != address(0), "balanceOf Function: Balance query for zero address");
        return balances[_owner];
    }


    function ownerOf(uint _tokenId) public view returns(address) {
        address owner = owners[_tokenId];
        require(owner != address(0),"ownerOf Function: non existing owner of tokenId");
        return owner;
    }


    function mint(address _to, uint _tokenId) public {
        require(_to != address(0),"Mint Function: Minting for zero Address");

        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer (address(0),_to,_tokenId);
    }

    function burn(uint _tokenId) public {
        address owner = ERC721.ownerOf(_tokenId); 
        
        approve(address(0),_tokenId);

        balances[owner] -= 1;
        delete owners[_tokenId];

        emit Transfer(owner,address(0),_tokenId);
    }


    function tokenURI(uint _tokenId) public view returns(string memory){
        require(exists(_tokenId),"tokenURI Function: Non-exist tokenId set URI ");
        string memory _baseURI = baseURI();

        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI,_tokenId.toString())):"";
    }

    function baseURI() internal pure returns(string memory){
        return "";
    }

    function msgSender() internal view returns(address){
        return msg.sender;
    }


    function approve(address _to, uint _tokenId) public  {
        tokenApprovals[_tokenId] = _to;
        emit Approval(ERC721.ownerOf(_tokenId), _to, _tokenId);
    }

     function getApproved(uint256 _tokenId) public view  returns (address) {
        require(exists(_tokenId), "ERC721: approved query for nonexistent token");

        return tokenApprovals[_tokenId];
    }

    
    function setApprovalForAll(address _operator, bool _approved) public  {
        setApprovalForAll(msgSender(), _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view  returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function isApprovedOrOwner(address _spender,uint _tokenId) internal view returns(bool) {
        require(exists(_tokenId),"isApprovedOrOwner: Non existing Token Id");
        address owner = ERC721.ownerOf(_tokenId);

        return(_spender == owner || isApprovedForAll(owner,_spender) || getApproved(_tokenId) == _spender);
    }

    function setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }


    function transfer(address _from, address _to, uint _tokenId) public  returns(bool) {
        address owner = ERC721.ownerOf(_tokenId);
        
        require(owner == _from, "transfer function: ERC721 transfer from incorrect owner");
        require(_to != address(0),"transfer function: ERC721 receiver address should not be zero address");
        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        return true;
    }

     function transferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) public  {
    
        require(isApprovedOrOwner(msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");

        transfer(_from, _to, _tokenId);
    }



}