// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {DefaultOperatorFilterer} from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";


abstract contract BlessAIO is ERC1155("https://blessaio/api/item/{id}.json"), DefaultOperatorFilterer, Ownable, ERC1155Pausable {
    mapping(address => bool) public whitelist;

    // The number of accounts we want to have in our whitelist.
    uint256 public maxNumberOfWhitelistedAddresses;

    // Track the number of whitelisted addresses.
    uint256 public numberOfAddressesWhitelisted;

    // The mint process 
    uint256 private _tokenMint; 
    bool private _whitelistSale = false;
    bool private _publicSale = false;

    constructor(uint256 _maxWhitelistedAddresses) {
        maxNumberOfWhitelistedAddresses = _maxWhitelistedAddresses;
    }

    function setPublicSale() external onlyOwner {
        _publicSale = !_publicSale;
    }

    function setWhitelistSale() external onlyOwner {
        _whitelistSale = !_whitelistSale;
    }

    function addToWhitelist(address[] calldata addAddresses) external onlyOwner {
        for (uint i = 0; i < addAddresses.length; i++) {
            whitelist[addAddresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] calldata removeAddresses) external onlyOwner {
        for (uint i = 0; i < removeAddresses.length; i++) {
            delete whitelist[removeAddresses[i]];
        }
    }

    function mint() external virtual {
      if(whitelist[_msgSender()] == true){
          require(
              _whitelistSale == true,
              "ERC1155: whitelist sale no is active"
          );

          _mintToken(_msgSender());
          delete whitelist[_msgSender()];
      } else {
          require(
              _publicSale == true,
              "ERC1155: public sale no is active"
          );
          _mintToken(_msgSender());
      }
    }

    function pause() public onlyOwner virtual {
      _pause();
    }

    function unpause() public onlyOwner virtual {
      _unpause();
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) 
    {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Pausable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _mintToken(address to) internal virtual {
      _tokenMint++;

      require(_tokenMint <= 10000, "ERC1155: mint maximum token");

      _mint(to, _tokenMint, 1, "0x00");
    }
}
