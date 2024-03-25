// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
// import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";

contract ERC20Facet {
    LibERC20.Storage internal l;

    function erc20name() external pure returns (string memory) {
        return "Auction Token";
    }

    function erc20symbol() external pure returns (string memory) {
        return "AUC";
    }

    function erc20decimals() external pure returns (uint8) {
        return 18;
    }

    function erc20totalSupply() public view returns (uint256) {
        return l._totalSupply;
    }

    function erc20balanceOf(
        address _owner
    ) public view returns (uint256 balance) {
        balance = l._balances[_owner];
    }

    function erc20transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        LibERC20.erc20transfer(_to, _value);
        success = true;
    }

    function erc20transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        address spender = _msgSender();
        return LibERC20.erc20transferFrom(spender, _from, _to, _value);
    }

    function erc20approve(address spender, uint256 amount) external {
        address owner = _msgSender();
        LibERC20.erc20approve(owner, spender, amount);
    }

    function erc20allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining_) {
        remaining_ = LibERC20._erc20allowance(_owner, _spender);
    }

    function erc20mint() external {
        LibDiamond.DiamondStorage storage d = LibDiamond.diamondStorage();
        address to = d.contractOwner;
        LibDiamond.enforceIsContractOwner();
        uint256 amount = 100_000_000e18;
        LibERC20.erc20mint(to, amount);
    }

    function _msgSender() private view returns (address) {
        return msg.sender;
    }
}