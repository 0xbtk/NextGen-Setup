// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ERC721} from "../../src/openzeppelin/ERC721.sol";

contract MockERC721 is ERC721 {

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function mint(address account, uint256 tokenId) public {
        super._safeMint(account, tokenId);
    }

}