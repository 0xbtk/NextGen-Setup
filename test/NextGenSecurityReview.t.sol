// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {TestSetup} from "./TestSetup.sol";
import {MockERC721} from "./Helpers/MockERC721.sol";

contract NextGenSecurityReview is TestSetup {
    function setUp() public override {
        super.setUp();
    }
    
    /*

    * Leave 1:     0xb0c62ba6b4f34159b7d0e56faed3aa0a721797be7971b42cadb1d2b53b08603d
    * Leave 2:     0xb0d96c69509384bd98691849996a4703764cebd4e1ab21b717fdf8534cb810f4
    * Leave 3:     0x620bc37436e5cac962dfcf514c481c6549fc81c43c8ea9faad034a94128c9b4a
    * Leave 4:     0x19e5952531384a811e98f9c7ec35209c06a2c91618a81847b2c137335b1e5605
    * L1&L2 Hash:  0x2ace43acde99f7691aa917d1674e4b6a9f53cc501fc2b8e1bd5d7ec97a0d5d0d
    * L3&L4 Hash:  0xab0ea5b149ddf67b9a209855d48b0af2a6d61d81b7512c6104a125d2ef1c7895
    * Merkle Root: 0xb7e5f32f7045ad68cbb9b4b1b353878f9345d9bf89aeb4c4274011a359fdd182

    */
}
