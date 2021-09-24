// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MoonstoneToken is ERC20('Moonstone', 'STONE'), Ownable {
    // set max supply
    uint256 constant private _maxTotalSupply = 1732050 ether; // set max supply to 1732050 (from theodores constant) $STONEs 

    // burn counter
    uint256 private _burnTotal;

    // minter address, we do this so that we can change farm later without having to migrate
    // token will be owned passed to a timelock after launch
    address private _minter;

    constructor(uint256 _initialSupply) {
        _minter = msg.sender;
        mint(address(msg.sender), _initialSupply);
    }


    // Minting functions. only minter can mint. only owner can set minter.
    function setMinter(address _newMinter) public onlyOwner {
        _minter=_newMinter;
    }

    function minter() public view returns(address){
        return _minter;
    }

    modifier onlyMinter() {
        require(msg.sender == _minter, 'Only Minter can mint!');
        _;
    }

     /// @notice Creates `_amount` token to `_to`. Must only be called by the minter.
     function mint(address _to, uint256 _amount) public onlyMinter {
        require(totalSupply() + _amount <= _maxTotalSupply, "ERC20: Minting is over! MaxTotalSupply has been minted.");
        _mint(_to, _amount);
    }

    // Returns maximum total supply of the token
    function getMaxTotalSupply() external pure returns (uint256) {
        return _maxTotalSupply;
    }
    
    // burn logic
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
        _burnTotal = _burnTotal + amount;
    }

    // interactive burn logic
    function burnFrom(address account, uint256 amount) public {
        require (allowance(account, _msgSender()) >= amount, 'Burn amount exceeds allowance');
        _burn(account, amount);
        _burnTotal = _burnTotal + amount;
        _approve(account, _msgSender(), allowance(account, _msgSender()) - amount);
    }

    // view total burnt morralla
    function totalBurned() public view returns (uint256) {
        return _burnTotal;
    }
}

