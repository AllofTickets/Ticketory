// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Main is ERC721, ERC721Enumerable, Ownable {
    uint256 public paperPrice;
    uint256 private _nextTokenId;
    mapping(uint256 => bool) public locked;
    mapping(uint256 => bool) public isused;
    mapping(uint256 => bytes32) public hashes;

    constructor(string memory name, string memory symbol, address initialOwner, uint256 _paperPrice)
        ERC721(name, symbol)
        Ownable(initialOwner)
    {
        paperPrice = _paperPrice;
    }

    /**
     * @notice Withdrawal of paper sales proceeds.
     */
    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @notice Buy paper
     */
    function buyPaper(bytes32 mHash) public payable {
        require(msg.value == paperPrice, "Incorrect amount sent");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        locked[tokenId] = true;
        hashes[tokenId] = mHash;
    }

    /**
     * @notice Set paper's price
     */
    function setPaperPrice(uint256 newPrice) public onlyOwner {
        paperPrice = newPrice;
    }

    /**
     * @notice Unlock paper
     */
    function unlockPaper(uint256 tokenId) public onlyOwner {
        require(locked[tokenId], "Paper is already unlocked");
        locked[tokenId] = false;
    }

    /**
     * @notice Use paper
     */
    function usePaper(uint256 tokenId, bytes32 mHash) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this ticket.");
        require(!isused[tokenId], "Paper is already used.");
        require(hashes[tokenId] == mHash, "Hash dose not match.");
        isused[tokenId] = true;
    }

    /**
     * @notice 
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        require(!locked[tokenId], "Paper is locked and cannot be transferred.");
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
