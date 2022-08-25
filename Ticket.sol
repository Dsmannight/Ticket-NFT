// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MyToken is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; // Counter to identify the current TokenID 

    /**
    * @dev Paramaters provided for deployment
    */
    uint256 venueSize;
    uint public mintRate;

   /**
    * @dev Constructor
    */
    constructor(
        string memory _eventName,
        string memory _ticketSymbol,
        uint256 _venueSize,
        uint256 _mintRate
    ) ERC721(_eventName, _ticketSymbol) {
        venueSize = _venueSize;
        mintRate = (_mintRate * 1 ether);
    }

/* MODIFIERS */

    /**
    * @dev Checks if we have tickets
    */
    modifier isAvailable(){
        require((_tokenIdCounter.current() < venueSize), "Sold out");
        _;
    }

/* FUNCTIONS */

    /**
    * @dev To Pause and unpause event, controls whenNotPaused modifier
    */
    function pause() public onlyOwner {
        _pause();
    }
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
    * @dev Minting a new Ticket
    */
    function safeMint(address to, uint256 _amount) public payable isAvailable whenNotPaused{
        // Require the amount of tickets wanting to be purchased does not exceed venue size
        require(_amount <= (venueSize - _tokenIdCounter.current()), "Not enough avaliable tickets");

        // Require that the wallet has enough to purchase tickets
        require(msg.value >= (mintRate * _amount), "Not enough ether");

        // For the amount of tickets purchased
        for(uint256 i = 0; i < _amount; i++){
            _tokenIdCounter.increment(); // Increment tokenId
            _safeMint(to, _tokenIdCounter.current()); // Mint ticket at current tokenId
        }
    }

    /**
    * @dev To transfer ticket from one wallet to another
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId); // Inheriting from OpenZeopplin
    }

}