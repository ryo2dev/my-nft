// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {IERC5192} from "./IERC5192.sol";

contract MyNFT is ERC1155, AccessControl, ERC1155Pausable, IERC5192 {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // as Soul Binding Token
    bool public isLocked = true;
    mapping(uint256 => bool) private _lockedEmitted;
    error ErrLocked();

    constructor() ERC1155("http://localhost:8000/{id}.json") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
        if (isLocked && !_lockedEmitted[id]) {
            emit Locked(id);
            _lockedEmitted[id] = true;
        }
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
        if (isLocked) {
            for (uint256 i = 0; i < ids.length; i++) {
                if (!_lockedEmitted[ids[i]]) {
                    emit Locked(ids[i]);
                    _lockedEmitted[ids[i]] = true;
                }
            }
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable)
    {
        require(!isLocked || from == address(0) || to == address(0), ErrLocked());

        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }

    function setLock(bool _isLocked) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isLocked = _isLocked;
    }

    function locked(uint256) public view override returns (bool) {
        return isLocked;
    }
}
