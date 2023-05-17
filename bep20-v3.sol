// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface TokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;

    function tokenFallback(
        address from,
        uint256 value,
        bytes calldata data
    ) external;
}


interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

   
    function balanceOf(address account) external view returns (uint256);

 
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract TrustedContracts is Ownable {

        mapping(address => bool) public trustedContracts;
        event TrustedContractUpdate(address _contractAddress, bool _added);


        function isContract(address _addr) private view returns (bool) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    function addTrustedContracts(address _contractAddress, bool _isActive)
        public
        onlyOwner
    {
        require(
            isContract(_contractAddress),
            "Only contract address can be added"
        );
        trustedContracts[_contractAddress] = _isActive;
        emit TrustedContractUpdate(_contractAddress, _isActive);
    }

     function notifyTrustedContract(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        // if the contract is trusted, notify it about the transfer
        if (trustedContracts[recipient]) {
            TokenRecipient trustedContract = TokenRecipient(recipient);
            bytes memory data;
            trustedContract.tokenFallback(sender, amount, data);
        }
    }

  
   
    function transferAnyBEP20Token(address _tokenAddress, uint256 _value)
        public
        onlyOwner
        returns (bool)
    {
        address _owner =owner();
        return IBEP20(_tokenAddress).transfer(_owner, _value);
    }

}

contract Freezable is Ownable {
    bool public emergencyFreeze;
    mapping(address => bool) public frozen;

    event LogFreezed(address indexed target, bool freezeStatus);
    event LogEmergencyFreezed(bool emergencyFreezeStatus);

    modifier unfreezed(address _account) {
        require(!frozen[_account], "Account is freezed");
        _;
    }

    modifier noEmergencyFreeze() {
        require(!emergencyFreeze, "Contract is emergency freezed");
        _;
    }

   
    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        require(_target != address(0), "Zero address not allowed");
        frozen[_target] = _freeze;
        emit LogFreezed(_target, _freeze);
    }

 
    function emergencyFreezeAllAccounts(bool _freeze) public onlyOwner {
        emergencyFreeze = _freeze;
        emit LogEmergencyFreezed(_freeze);
    }
}


contract BEP20 is ERC20, ERC20Burnable, Pausable, Ownable , Freezable , TrustedContracts{

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


    function _transfer( address from, address to,uint256 amount) 
           internal
           unfreezed(from)
        unfreezed(to)
        override
    {
        super._transfer(from,to ,amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
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