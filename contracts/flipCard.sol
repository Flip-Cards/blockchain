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

    //This is the brand head wallet address to make them the default admin on the blockchain
    address public brandAddress;

    constructor() ERC721("FlipCards", "FCRDS") {
        //Called when the blockchain starts
        //This way the person initializing the blockchain have all the necessary roles
        //These roles are just provided for readiblity and scope assessment, just DEFAULT_ADMIN_ROLE is equivalent to these

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(HANDLER_ROLE, msg.sender);
        _grantRole(BOOK_KEEPER_ROLE, msg.sender);

        //when the contract lits up we want to assign the default address to brandAddress
        brandAddress = 0x6fA75265a8A8CfEB7eB798248fab22dAe8b9bccD;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(HANDLER_ROLE, msg.sender);
        _grantRole(BOOK_KEEPER_ROLE, msg.sender);
        //This way the brand owner will be the Admin since the contract starts
    }

    /// Return 'true' if the account belongs to a minter
    function isMinter(address _account) public view virtual returns (bool) {
        return
            hasRole(DEFAULT_ADMIN_ROLE, _account) ||
            hasRole(MINTER_ROLE, _account);
    }

    /// Restricted to the minters of the NFT
    modifier onlyMinter() {
        //user who can mint a new NFT
        require(isMinter(msg.sender), "Restricted to owner and minters");
        _;
    }

    /// Return 'true' if the account is the admin account
    function isAdmin(address _account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _account);
    }

    /// Restricted to the minters of the NFT
    modifier onlyAdmin() {
        //user who can mint a new NFT
        require(isAdmin(msg.sender), "Restricted to only admin");
        _;
    }

    /// Return 'true' if the account can update the NFT
    function isUpdateMember(address _account)
        public
        view
        virtual
        returns (bool)
    {
        return
            hasRole(DEFAULT_ADMIN_ROLE, _account) ||
            hasRole(BOOK_KEEPER_ROLE, _account);
    }

    modifier onlyUpdateMember() {
        require(
            isUpdateMember(msg.sender),
            "Member is not allowed to update the NFT"
        );
        _;
    }

    ///updates all the present roles for the given address
    ///Ths private function will not be accessible outside the blockchain
    function makeSuperAdmin(address _member) private {
        addRole(_member, MINTER_ROLE);
        addRole(_member, DEFAULT_ADMIN_ROLE);
        addRole(_member, HANDLER_ROLE);
        addRole(_member, BOOK_KEEPER_ROLE);
    }

    /// updates the roles for the passed address
    function addRole(address _member, bytes32 _role) public virtual onlyAdmin {
        /**
        member -> address of user whose role we need to update
        role -> string defining the role for member
         */
        require(
            _role == MINTER_ROLE ||
                _role == HANDLER_ROLE ||
                _role == BOOK_KEEPER_ROLE,
            "Defined role doesn't exists"
        );
        grantRole(_role, _member);
    }

    /// Safely mint a new NFT
    function safeMint(address to, string memory uri) public onlyMinter {
        /**
        to -> contract address on which the NFT needs to be minted
        uri -> The uri of the token generating
         */
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    ///utility function to convert a byte32 into a string
    function bytes32ToString(bytes32 x) public pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        uint256 j;
        for (j = 0; j < 32; j++) {
            bytes1 char = bytes1(bytes32(uint256(x) * 2**(8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    /// batch mint NFTs
    function safeMintBatch(address to, string[] calldata _newTokenURIs)
        public
        onlyMinter
    {
        uint256 i = 0;
        for (i = 0; i < _newTokenURIs.length; i++) {
            //batch mint NFTs from the given array of token containing tokenURIs
            safeMint(to, _newTokenURIs[i]);
        }
    }

    function updateTokenUri(uint256 _tokenId, string memory _tokenURI)
        public
        onlyUpdateMember
        returns (bool)
    {
        /**
        Only user with the access to the updation request can update the URI token
         */
        _setTokenURI(_tokenId, _tokenURI);
        return true;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function heartbeat() public pure returns (uint256) {
        /**
        Helps to check on the connecting frontend if the connectino is possible
         */
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

    //// when token is sent on this chain it must return the magic value
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
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
