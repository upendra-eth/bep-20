// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BEP20 is ERC20, ERC20Burnable, Pausable, Ownable {

   uint256 public TotalSupply = 85_000_000 * 10**18; // 85 million tokens with 18 decimals


    address public communityMiningStaking;
    address public reserve;
    address public treasury;
    address public team;
    address public web3Foundation;




    constructor(
        address _communityMiningStaking,
        address _reserve,
        address _treasury,
        address _team,
        address _web3Foundation
    )  ERC20("Streakk","STKK") {

        communityMiningStaking = _communityMiningStaking;
        reserve = _reserve;
        treasury = _treasury;
        team = _team;
        web3Foundation = _web3Foundation;

        // Allocate tokens to respective addresses
        mint(_communityMiningStaking, TotalSupply * 50 / 100);
        mint(_reserve, TotalSupply * 10 / 100);
        mint(_treasury, TotalSupply * 15 / 100);
        mint(_team, TotalSupply * 5 / 100);
        mint(_web3Foundation, TotalSupply * 20 / 100);
    }


    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function GetChainID() public  view returns (uint256) {
          uint256 id = block.chainid;
          return  id;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

        function transferAnyBEP20Token(address _tokenAddress ,address to, uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        return IERC20(_tokenAddress).transfer(to, _value);
    }

     function bulkTransfer(address[] memory recipients, uint256[] memory amounts)
        public
        returns (bool)
    {
        require(recipients.length == amounts.length, "Invalid length");
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        return true;
    }

    function bulkTransferFrom(
        address sender,
        address[] memory recipients,
        uint256[] memory amounts
    ) public returns (bool) {
        require(recipients.length == amounts.length, "Invalid length");
        for (uint256 i = 0; i < recipients.length; i++) { 
              transferFrom( sender,recipients[i],  amounts[i]);
        }
        return true;
    }
}