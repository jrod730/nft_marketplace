// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4; // set version to match with waht we have in our hardhat configuration

// Using ERC721 standard
// Functionality we can use
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NftMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 _listingFee = 0.025 ether;

    address payable _owner;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated (
        uint256 tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() ERC721("OwnerFans", "OF") {
        _owner = payable(msg.sender);
    }

    function updateListingFee(uint listingFee) public payable
    {
        require(_owner == msg.sender, "Only owner of NFT Marketplace can update the listing fee.");

        _listingFee = listingFee;
    }

    function getListingPrice() public view returns (uint256)
    {
        return _listingFee;
    }

    function createToken (string memory tokenUri, uint256 price) public payable returns (uint)
    {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenUri);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    function createMarketItem (uint256 tokenId, uint256 price) private 
    {
        require (price > 0, "Price must higher than 0");
        require(msg.value == _listingFee, "Price must be equal to listing fee");

        idToMarketItem[tokenId] = MarketItem(
            tokenId, 
            payable(msg.sender), 
            payable(address(this)), 
            price, 
            false
        );

        // look up safe transfer.
        _transfer(msg.sender, address(this), tokenId);

        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    } 

    function resellToken (uint256 tokenId, uint256 price) public payable 
    {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only NFT owner can resell a NFT");
        require(msg.value == _listingFee, "Price must be equal to listing fee");

        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    function createMarketSale (uint256 tokenId) public payable 
    {
        uint price = idToMarketItem[tokenId].price;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase.");

        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));

        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenId);

        payable(_owner).transfer(_listingFee);
        payable(idToMarketItem[tokenId].seller).transfer(msg.value);
    }

    function fetchMarketItems () public view returns (MarketItem[] memory) 
    {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();

        return getMarketItemsByOwner(itemCount, unsoldItemCount);
    }

    function fetchUserNfts () public view returns (MarketItem[] memory) 
    {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;

        for (uint i = 0; i < totalItemCount; i++)
        {
            if (idToMarketItem[i + 1].owner == msg.sender)
            {
                itemCount += 1;
            }
        }

        return getMarketItemsByOwner(itemCount, totalItemCount);
    }

    function getMarketItemsByOwner (uint itemCount, uint totalItems) private view returns (MarketItem[] memory) 
    {
        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItems; i++)
        {
            if (idToMarketItem[i + 1].owner == msg.sender)
            {
                uint currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;

                currentIndex += 1;            
            }
        }

        return items;    
    }

    function fetchNftsListed () public view returns (MarketItem[] memory)
    {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;

        for (uint i = 0; i < totalItemCount; i++)
        {
            if (idToMarketItem[i + 1].seller == msg.sender)
            {
                itemCount += 1;
            }
        }

        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++)
        {
            if (idToMarketItem[i + 1].seller == msg.sender)
            {
                uint currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;

                currentIndex += 1;            
            }
        }

        return items;    
    }
}
