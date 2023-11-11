// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {NextGenCore} from "../src/NextGenCore.sol";
import {NextGenAdmins} from "../src/NextGenAdmins.sol";
import {MinterContract} from "../src/MinterContract.sol";
import {DelegationManagementContract} from "../src/out-scope/DelegationManagementContract.sol";
import {XRandoms} from "../src/XRandoms.sol";
import {RandomizerNXT} from "../src/RandomizerNXT.sol";
import {AuctionDemo} from "../src/AuctionDemo.sol";

import {MockERC721} from "./Helpers/MockERC721.sol";

contract TestSetup is Test {
    NextGenCore internal nextGenCore;
    NextGenAdmins internal nextGenAdmins;
    MinterContract internal minterContract;
    DelegationManagementContract internal delegationManagement;
    XRandoms internal xRandoms;
    RandomizerNXT internal randomizerNXT;
    AuctionDemo internal auctionDemo;

    address internal genAdminOwner = makeAddr("genAdminOwner");

    address internal delegatee = makeAddr("delegatee");

    address internal artist1 = makeAddr("artist1");
    address internal artistPyAdd1 = makeAddr("artistPyAdd1");
    address internal artistPyAdd2 = makeAddr("artistPyAdd2");
    address internal artistPyAdd3 = makeAddr("artistPyAdd3");
    address internal artistSPyAdd1 = makeAddr("artistSPyAdd1");
    address internal artistSPyAdd2 = makeAddr("artistSPyAdd2");
    address internal artistSPyAdd3 = makeAddr("artistSPyAdd3");
    address internal receiver = makeAddr("receiver");

    address internal bidder1 = makeAddr("bidder1");
    address internal bidder2 = makeAddr("bidder2");
    address internal bidder3 = makeAddr("bidder3");

    address internal whitelisted1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address internal whitelisted2 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    address internal whitelisted3 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address internal whitelisted4 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    bytes32 internal MERKLE_ROOT;

    function setUp() public virtual {
        vm.startPrank(genAdminOwner);

        nextGenAdmins = new NextGenAdmins();
        nextGenCore = new NextGenCore(
            "Next Gen Core",
            "NEXTGEN",
            address(nextGenAdmins)
        );
        delegationManagement = new DelegationManagementContract();
        minterContract = new MinterContract(
            address(nextGenCore),
            address(delegationManagement),
            address(nextGenAdmins)
        );
        xRandoms = new XRandoms();
        randomizerNXT = new RandomizerNXT(
            address(xRandoms),
            address(nextGenAdmins),
            address(nextGenCore)
        );

        auctionDemo = new AuctionDemo(
            address(minterContract),
            address(nextGenCore),
            address(nextGenAdmins)
        );

        nextGenCore.addMinterContract(address(minterContract));
        nextGenAdmins.registerCollectionAdmin(1, artist1, true);
        nextGenAdmins.registerCollectionAdmin(2, artist1, true);
        nextGenAdmins.registerCollectionAdmin(3, artist1, true);

        vm.stopPrank();

        vm.label(address(nextGenAdmins), "nextGenAdmins");
        vm.label(address(nextGenCore), "nextGenCore");
        vm.label(address(minterContract), "minterContract");
        vm.label(address(delegationManagement), "delegationManagement");
        vm.label(address(xRandoms), "xRandoms");
        vm.label(address(randomizerNXT), "randomizerNXT");
        vm.label(address(auctionDemo), "auctionDemo");
        vm.label(genAdminOwner, "genAdminOwner");
        vm.label(artist1, "artist1");
        vm.label(receiver, "receiver");
        vm.label(bidder1, "bidder1");
        vm.label(bidder2, "bidder2");
        vm.label(bidder3, "bidder3");
        vm.label(whitelisted1, "whitelisted1");
        vm.label(whitelisted2, "whitelisted2");
        vm.label(whitelisted3, "whitelisted3");
        vm.label(whitelisted4, "whitelisted4");
        vm.label(delegatee, "delegatee");

        MERKLE_ROOT = generateMerkleRoot();

        collectionOneSetup();
        delegationSetup();
    }

    function collectionOneSetup() public {
        string[] memory collectionScript = new string[](1);
        collectionScript[0] = "Collection1Image";
        vm.prank(genAdminOwner);
        nextGenCore.createCollection({
            _collectionName: "Collection1",
            _collectionArtist: "Artist1",
            _collectionDescription: "Description1",
            _collectionWebsite: "Collection1.xyz",
            _collectionLicense: "MIT",
            _collectionBaseURI: "Collection1.xyz",
            _collectionLibrary: "p5.js",
            _collectionScript: collectionScript
        });

        vm.prank(artist1);
        nextGenCore.setCollectionData({
            _collectionID: 1,
            _collectionArtistAddress: artist1,
            _maxCollectionPurchases: 5,
            _collectionTotalSupply: 5,
            _setFinalSupplyTimeAfterMint: 4 weeks
        });

        vm.prank(genAdminOwner);
        nextGenCore.addRandomizer({
            _collectionID: 1,
            _randomizerContract: address(randomizerNXT)
        });

        vm.prank(artist1);
        minterContract.setCollectionCosts({
            _collectionID: 1,
            _collectionMintCost: 1e18,
            _collectionEndMintCost: 1e18,
            _rate: 0,
            _timePeriod: 1,
            _salesOption: 0,
            _delAddress: address(0)
        });

        vm.prank(artist1);
        minterContract.setCollectionPhases({
            _collectionID: 1,
            _allowlistStartTime: block.timestamp,
            _allowlistEndTime: block.timestamp,
            _publicStartTime: block.timestamp,
            _publicEndTime: block.timestamp + 3 days,
            _merkleRoot: bytes32(0)
        });
    }

    function burnToMintCollectionSetup() public {
        string[] memory collectionScript = new string[](1);
        collectionScript[0] = "CollectionBurnImage";

        vm.prank(genAdminOwner);
        nextGenCore.createCollection({
            _collectionName: "CollectionBurn",
            _collectionArtist: "Artist1",
            _collectionDescription: "DescriptionBurn",
            _collectionWebsite: "CollectionBurn.xyz",
            _collectionLicense: "MIT",
            _collectionBaseURI: "CollectionBurn.xyz",
            _collectionLibrary: "p5.js",
            _collectionScript: collectionScript
        });

        vm.prank(artist1);
        nextGenCore.setCollectionData({
            _collectionID: 2,
            _collectionArtistAddress: artist1,
            _maxCollectionPurchases: 2,
            _collectionTotalSupply: 20,
            _setFinalSupplyTimeAfterMint: 1 weeks
        });

        vm.prank(genAdminOwner);
        nextGenCore.addRandomizer({
            _collectionID: 2,
            _randomizerContract: address(randomizerNXT)
        });

        vm.prank(artist1);
        minterContract.setCollectionCosts({
            _collectionID: 2,
            _collectionMintCost: 1e17,
            _collectionEndMintCost: 1e17,
            _rate: 0,
            _timePeriod: 0,
            _salesOption: 0,
            _delAddress: address(0)
        });

        vm.prank(artist1);
        minterContract.setCollectionPhases({
            _collectionID: 2,
            _allowlistStartTime: 0,
            _allowlistEndTime: 0,
            _publicStartTime: block.timestamp,
            _publicEndTime: block.timestamp + 3 days,
            _merkleRoot: bytes32(0)
        });
    }

    function collectionTwoSetup() public {
        string[] memory collectionScript = new string[](1);
        collectionScript[0] = "Collection2Image";
        vm.prank(genAdminOwner);
        nextGenCore.createCollection({
            _collectionName: "Collection2",
            _collectionArtist: "Artist1",
            _collectionDescription: "Description2",
            _collectionWebsite: "Collection2.xyz",
            _collectionLicense: "MIT",
            _collectionBaseURI: "Collection2.xyz",
            _collectionLibrary: "p5.js",
            _collectionScript: collectionScript
        });

        vm.prank(artist1);
        nextGenCore.setCollectionData({
            _collectionID: 2,
            _collectionArtistAddress: artist1,
            _maxCollectionPurchases: 5,
            _collectionTotalSupply: 50,
            _setFinalSupplyTimeAfterMint: 4 weeks
        });

        vm.prank(genAdminOwner);
        nextGenCore.addRandomizer({
            _collectionID: 2,
            _randomizerContract: address(randomizerNXT)
        });

        vm.prank(artist1);
        minterContract.setCollectionCosts({
            _collectionID: 2,
            _collectionMintCost: 2e18,
            _collectionEndMintCost: 2e18,
            _rate: 0,
            _timePeriod: 0,
            _salesOption: 0,
            _delAddress: address(0)
        });

        vm.prank(artist1);
        minterContract.setCollectionPhases({
            _collectionID: 2,
            _allowlistStartTime: 0,
            _allowlistEndTime: 0,
            _publicStartTime: block.timestamp,
            _publicEndTime: block.timestamp + 3 days,
            _merkleRoot: bytes32(0)
        });
    }

    function erc721MockSetup() public returns (MockERC721 externalERC721) {
        externalERC721 = new MockERC721("CryptoPunk", "C");
    }

    function delegationSetup() public {
        vm.prank(whitelisted1);
        delegationManagement.registerDelegationAddress({
            _collectionAddress: 0x8888888888888888888888888888888888888888,
            _delegationAddress: delegatee,
            _expiryDate: block.timestamp + 2 days,
            _useCase: 2,
            _allTokens: true,
            _tokenId: 10000000000
        });
    }

    function addressesAndPercentagesSetup() public {
        vm.prank(genAdminOwner);
        minterContract.setPrimaryAndSecondarySplits({
            _collectionID: 1,
            _artistPrSplit: 80,
            _teamPrSplit: 20,
            _artistSecSplit: 70,
            _teamSecSplit: 30
        });

        vm.prank(artist1);
        minterContract.proposePrimaryAddressesAndPercentages({
            _collectionID: 1,
            _primaryAdd1: artistPyAdd1,
            _primaryAdd2: artistPyAdd2,
            _primaryAdd3: artistPyAdd3,
            _add1Percentage: 30,
            _add2Percentage: 30,
            _add3Percentage: 20
        });

        vm.prank(artist1);
        minterContract.proposeSecondaryAddressesAndPercentages({
            _collectionID: 1,
            _secondaryAdd1: artistSPyAdd1,
            _secondaryAdd2: artistSPyAdd2,
            _secondaryAdd3: artistSPyAdd3,
            _add1Percentage: 25,
            _add2Percentage: 25,
            _add3Percentage: 20
        });

        vm.prank(genAdminOwner);
        minterContract.acceptAddressesAndPercentages({
            _collectionID: 1,
            _statusPrimary: true,
            _statusSecondary: true
        });
    }

    function generateMerkleRoot() internal view returns (bytes32) {
        address[] memory allowList = new address[](4);
        allowList[0] = whitelisted1;
        allowList[1] = whitelisted2;
        allowList[2] = whitelisted3;
        allowList[3] = whitelisted4;

        uint256[] memory spots = new uint256[](4);
        spots[0] = 2;
        spots[1] = 3;
        spots[2] = 2;
        spots[3] = 1;

        string[] memory txinfo = new string[](4);
        txinfo[0] = '{"name":"hello"}';
        txinfo[1] = '{"name":"punk"}';
        txinfo[2] = '{"name":"seize"}';
        txinfo[3] = '{"name":"nextgen"}';

        bytes32[] memory leaves = new bytes32[](allowList.length);

        for (uint256 i = 0; i < allowList.length; i++) {
            bytes memory concatenatedData = abi.encodePacked(
                allowList[i],
                spots[i],
                txinfo[i]
            );
            leaves[i] = keccak256(concatenatedData);
        }

        uint256 numLeaves = leaves.length;

        if (numLeaves == 0) {
            return bytes32(0);
        }

        uint256 nextLevelSize = numLeaves;
        bytes32[] memory currentLevel = leaves;

        while (nextLevelSize > 1) {
            uint256 newSize = (nextLevelSize + 1) / 2;
            bytes32[] memory newLevel = new bytes32[](newSize);

            for (uint256 i = 0; i < newSize; i++) {
                if (2 * i + 1 < nextLevelSize) {
                    newLevel[i] = keccak256(
                        abi.encodePacked(
                            currentLevel[2 * i],
                            currentLevel[2 * i + 1]
                        )
                    );
                } else {
                    newLevel[i] = currentLevel[2 * i];
                }
            }

            currentLevel = newLevel;
            nextLevelSize = newSize;
        }

        return currentLevel[0];
    }

    function setUpArrayUint(
        uint256 length
    ) public pure returns (uint256[] memory array) {
        array = new uint256[](length);
    }

    function setUpArrayString(
        uint256 length
    ) public pure returns (string[] memory array) {
        array = new string[](length);
    }

    function setUpArrayAddress(
        uint256 length
    ) public pure returns (address[] memory array) {
        array = new address[](length);
    }

    function setUpArrayBytes(
        uint256 length
    ) public pure returns (bytes32[] memory array) {
        array = new bytes32[](length);
    }
}
