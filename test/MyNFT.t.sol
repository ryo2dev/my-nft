// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";
import {IERC5192} from "../src/IERC5192.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MyNFTTest is Test, ERC1155Holder {
    event Locked(uint256 tokenId);

    MyNFT public instance;
    address owner;
    address recipient;
    uint256 tokenId;
    uint256 value;

    function setUp() public {
        instance = new MyNFT();
        owner = address(this);
        recipient = makeAddr("recipient");
        tokenId = 123;
        value = 1;
    }

    function test_Mint() public {
        string memory uri = "http://localhost:8000/{id}.json";

        vm.expectEmit();
        emit Locked(tokenId);
        instance.mint(recipient, tokenId, value, "");

        assertEq(instance.balanceOf(recipient, tokenId), value);
        assertEq(instance.uri(tokenId), uri);
    }

    function test_SoulboundIsSupported() public view {
        assertEq(type(IERC5192).interfaceId, bytes4(0xb45a3c0e));
        assertTrue(instance.supportsInterface(type(IERC5192).interfaceId));
    }

    function test_TransferIsLocked() public {
        instance.mint(owner, tokenId, value, "");

        vm.expectRevert(MyNFT.ErrLocked.selector);
        instance.safeTransferFrom(owner, recipient, tokenId, value, "");

        assertEq(instance.balanceOf(owner, tokenId), value);
        assertNotEq(instance.balanceOf(recipient, tokenId), value);
    }

    function test_UnlockedTransfer() public {
        instance.setLock(false);
        instance.mint(owner, tokenId, value, "");

        instance.safeTransferFrom(owner, recipient, tokenId, value, "");

        assertEq(instance.balanceOf(recipient, tokenId), value);
        assertNotEq(instance.balanceOf(owner, tokenId), value);
    }
}
