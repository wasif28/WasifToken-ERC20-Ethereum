// Containts "SPDX-License-Identifier: MIT" ERC20 Token Standard

pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


abstract contract publicTokenBurner is ERC20{

    function burnTokens(uint amount) external returns (bool){
        _burn(msg.sender, amount);

        return true;
    }

}

abstract contract mintAuthroity is ERC20{

    address public mintingAuthority;

    function mintTokens(address to, uint amount) external {
        require(msg.sender == mintingAuthority, 'Only Authority Minter can Mint');

        _mint(to,amount);
    }

    function changeMinterAuthority(address newMintAuthority) external returns (bool) {
        require(msg.sender == mintingAuthority, 'Only Authority Minter can change mintAuthority');

        mintingAuthority = newMintAuthority;
        return true;
    }

}

abstract contract pausedFeature is ERC20, mintAuthroity{

    bool public isPauseActive;

    event Paused(address account);

    event Unpaused(address account);

    function isPaused() public view virtual returns (bool){
        return isPauseActive;
    }

    function pauseToken() virtual external {
        require (isPaused() == false, "Already Paused");
        require (msg.sender == mintingAuthority);
        isPauseActive = true;

        emit Paused(msg.sender);
    }

    function unPauseToken() virtual external {
        require (isPaused() == true, "Already Unpaused");
        require (msg.sender == mintingAuthority);
        isPauseActive = false;

        emit Unpaused(msg.sender);
    }



}

contract WasifToken is ERC20, mintAuthroity, publicTokenBurner, pausedFeature{


    constructor() ERC20('WasifToken', 'WASIF') {

        mintingAuthority = msg.sender;
        isPauseActive = false;

        _mint(msg.sender, 64000000 * 10 ** 18); // 64 million

    }

    function myBalance() public view returns(uint amount){
        return balanceOf(msg.sender);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(isPauseActive == false, "ERC20Pausable: token transfer while paused");
    }

}
