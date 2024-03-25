// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "../contracts/Diamond.sol";

import "../contracts/facets/ERC20Facet.sol";
import {AuctionMarketPlaceFacet} from "../contracts/facets/AuctionMarketPlaceFacet.sol";
import {LibAppStorage} from "../contracts/libraries/LibAppStorage.sol";
import {LibERC20} from "../contracts/libraries/LibERC20.sol";
import {NFTONE} from "../contracts/NFTONE.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;

    ERC20Facet erc20Facet;
    AuctionMarketPlaceFacet auctionF;
    NFTONE nftone;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Facet = new ERC20Facet();
        auctionF = new AuctionMarketPlaceFacet();
        nftone = new NFTONE();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(erc20Facet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        cut[3] = (
            FacetCut({
                facetAddress: address(auctionF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("AuctionMarketPlaceFaucet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    address A = mkaddr("staker a");
    address B = mkaddr("staker b");

    function testERC20Mint() public {
        ERC20Facet(address(diamond)).erc20mint();
        ERC20Facet(address(diamond)).erc20transfer(A, 50_000_000e18);
    }

    function testNFTONEMint() public {
        NFTONE(address(nftone)).safeMint(A, 0, "");
        NFTONE(address(nftone)).name();
        NFTONE(address(nftone)).symbol();
        address _owner = NFTONE(address(nftone)).ownerOf(0);
        uint iud = NFTONE(address(nftone)).balanceOf(A);
        assertEq(iud, 1);
        assertEq(A, _owner);
    }

    function testAuctionCreation() public {
        testNFTONEMint();
        vm.prank(A);
        NFTONE(address(nftone)).approve(address(diamond), 0);
        AuctionMarketPlaceFacet l = AuctionMarketPlaceFacet(address(diamond));
        l.createAuction(
            LibAppStorage.Categories.ERC721,
            address(nftone),
            address(diamond),
            0,
            block.timestamp + 100,
            10_000_000e18,
            0,
            ""
        );
    }
}


















// pragma solidity ^0.8.0;

// import "../contracts/interfaces/IDiamondCut.sol";
// import "../contracts/facets/DiamondCutFacet.sol";
// import "../contracts/facets/DiamondLoupeFacet.sol";
// import "../contracts/facets/OwnershipFacet.sol";

// import "../contracts/facets/ERC20Facet.sol";
// import {AuctionMarketPlaceFaucet} from "../contracts/facets/AuctionMarketPlaceFaucet.sol";

// import {NFTONE} from "../contracts/NFTONE.sol";
// import "forge-std/Test.sol";
// import "../contracts/Diamond.sol";

// contract DiamondDeployer is Test, IDiamondCut {
//     //contract types of facets to be deployed
//     Diamond diamond;
//     DiamondCutFacet dCutFacet;
//     DiamondLoupeFacet dLoupe;
//     OwnershipFacet ownerF;
//     ERC20Facet erc20Facet;
//     AuctionMarketPlaceFaucet auctionFaucet;
//     NFTONE nft;

//     address A = address(0xa);
//     address B = address(0xb);
//     address C = address(0xc);
//     address D = address(0xd);

//     AuctionMarketPlaceFaucet boundAuctionMarketPlace;

//     function setUp() public {
//         A = mkaddr("user a");

//         //deploy facets
//         dCutFacet = new DiamondCutFacet();
//         diamond = new Diamond(address(this), address(dCutFacet));
//         dLoupe = new DiamondLoupeFacet();
//         ownerF = new OwnershipFacet();
//         erc20Facet = new ERC20Facet();
//         auctionFaucet = new AuctionMarketPlaceFaucet();
//         nft = new NFTONE(A, "NFT Sample", "ONC");

//         //upgrade diamond with facets

//         //build cut struct
//         FacetCut[] memory cut = new FacetCut[](4);

//         cut[0] = (
//             FacetCut({
//                 facetAddress: address(dLoupe),
//                 action: FacetCutAction.Add,
//                 functionSelectors: generateSelectors("DiamondLoupeFacet")
//             })
//         );

//         cut[1] = (
//             FacetCut({
//                 facetAddress: address(ownerF),
//                 action: FacetCutAction.Add,
//                 functionSelectors: generateSelectors("OwnershipFacet")
//             })
//         );

//         cut[2] = (
//             FacetCut({
//                 facetAddress: address(auctionFaucet),
//                 action: FacetCutAction.Add,
//                 functionSelectors: generateSelectors("AuctionMarketPlaceFaucet")
//             })
//         );

//         cut[3] = (
//             FacetCut({
//                 facetAddress: address(erc20Facet),
//                 action: FacetCutAction.Add,
//                 functionSelectors: generateSelectors("ERC20Facet")
//             })
//         );

//         //upgrade diamond
//         IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

//         //call a function
//         DiamondLoupeFacet(address(diamond)).facetAddresses();

//         B = mkaddr("user b");
//         C = mkaddr("user c");
//         D = mkaddr("user d");

//         // mint AUC tokens
//         ERC20Facet(address(diamond)).mintTo(A);
//         ERC20Facet(address(diamond)).mintTo(B);
//         ERC20Facet(address(diamond)).mintTo(C);
//         ERC20Facet(address(diamond)).mintTo(D);

//         // bind the auction market place
//         boundAuctionMarketPlace = AuctionMarketPlaceFaucet(address(diamond));
//     }

//     function generateSelectors(
//         string memory _facetName
//     ) internal returns (bytes4[] memory selectors) {
//         string[] memory cmd = new string[](3);
//         cmd[0] = "node";
//         cmd[1] = "scripts/genSelectors.js";
//         cmd[2] = _facetName;
//         bytes memory res = vm.ffi(cmd);
//         selectors = abi.decode(res, (bytes4[]));
//     }

//     function testGetAuctionMarketPlaceName() public {
//         switchSigner(A);
//         string memory auction = boundAuctionMarketPlace.name();

//         console.log("auction name", auction);
//     }

//     function mkaddr(string memory name) public returns (address) {
//         address addr = address(
//             uint160(uint256(keccak256(abi.encodePacked(name))))
//         );
//         vm.label(addr, name);
//         return addr;
//     }

//     function switchSigner(address _newSigner) public {
//         address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
//         if (msg.sender == foundrySigner) {
//             vm.startPrank(_newSigner);
//         } else {
//             vm.stopPrank();
//             vm.startPrank(_newSigner);
//         }
//     }

//     function diamondCut(
//         FacetCut[] calldata _diamondCut,
//         address _init,
//         bytes calldata _calldata
//     ) external override {}
// }