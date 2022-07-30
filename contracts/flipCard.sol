// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-solidity/contracts/access/AccessControl.sol";
import "openzeppelin-solidity/contracts/utils/Counters.sol";

contract flipCard is ERC721, ERC721URIStorage, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // can mint new NFTs
    bytes32 public constant HANDLER_ROLE = keccak256("HANDLER_ROLE"); //can handle repair and repairments
    bytes32 public constant BOOK_KEEPER_ROLE = keccak256("BOOK_KEEPER_ROLE"); // can transfer the NFTs to anyone & update their issue dates
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("FlipCards", "FCRDS") {
        //Called when the blockchain starts
        //This way the person initializing the blockchain have all the necessary roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        //These roles are just provided for readiblity and scope assessment, just DEFAULT_ADMIN_ROLE is equivalent to these
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(HANDLER_ROLE, msg.sender);
        _grantRole(BOOK_KEEPER_ROLE, msg.sender);
    }

    /// Return 'true' if the account belongs to a minter
    function isMinter(address account) public view virtual returns (bool) {
        return
            hasRole(DEFAULT_ADMIN_ROLE, account) ||
            hasRole(MINTER_ROLE, account);
    }

    /// Restricted to the minters of the NFT
    modifier onlyMinter() {
        //user who can mint a new NFT
        require(isMinter(msg.sender), "Restricted to owner and minters");
        _;
    }

    /// Return 'true' if the account is the admin account
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// Restricted to the minters of the NFT
    modifier onlyAdmin() {
        //user who can mint a new NFT
        require(isAdmin(msg.sender), "Restricted to only admin");
        _;
    }

    /// updates the roles for the passed address
    function addRole(address member, bytes32 role) public virtual onlyAdmin {
        /**
        member -> address of user whose role we need to update
        role -> string defining the role for member
         */
        require(
            role == MINTER_ROLE ||
                role == HANDLER_ROLE ||
                role == BOOK_KEEPER_ROLE
        );
        grantRole(role, member);
    }

    function safeMint(address to, string memory uri) public onlyMinter {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
    function heartbear() public returns(uint256){
        return 1;
    }
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
