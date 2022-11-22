// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/presets/ERC1155PresetMinterPauser.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 *
 * _Deprecated in favor of https://wizard.openzeppelin.com/[Contracts Wizard]._
 */
contract Bless is
    Context,
    AccessControlEnumerable,
    ERC1155Pausable
{
    using SafeMath for uint256;

    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 private _tokenMint = 0;
    bool private _publicSale = false;

    mapping(address => uint256) private _totalAccountPurchase;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `WHITELIST_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    constructor(string memory uri) ERC1155(uri) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function addAccountWhitelist(address _to) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "ERC1155: must have admin role to add"
        );

        _setupRole(WHITELIST_ROLE, _to);
    }

    function mint() public virtual {
        if(hasRole(WHITELIST_ROLE, _msgSender())){
            _mintToken(_msgSender());
            _revokeRole(WHITELIST_ROLE, _msgSender());
        }else {
            require(
                _publicSale == true,
                "ERC1155: public sale no is active"
            );
            require(
                _totalAccountPurchase[_msgSender()] > 3,
                "ERC1155: public sale no is active"
            );

            _totalAccountPurchase[_msgSender()] = _totalAccountPurchase[_msgSender()].add(1);
            _mintToken(_msgSender());
        }
    }

    function _mintToken(address to) internal virtual {
        _tokenMint++;

        require(_tokenMint <= 10000, "ERC1155: mint maximum token ");

        _mint(to, _tokenMint, 1, "0x00");
    }

    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC1155PresetMinterPauser: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC1155PresetMinterPauser: must have pauser role to unpause"
        );
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC1155)
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
}
