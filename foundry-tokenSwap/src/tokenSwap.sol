//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// 100 tokenA can be exchanged with 300 tokenB,input amount is taken considering that
contract tokenSwap {
    IERC20 tokenA;
    address ownerA;
    uint amntA_toSwap;
    IERC20 tokenB;
    address ownerB;
    uint amntB_toSwap;

    constructor(
        address _tokenA,
        address _tokenB,
        uint amntA,
        uint amntB,
        address _ownerA,
        address _ownerB
    ) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        amntA_toSwap = amntA;
        amntB_toSwap = amntB;
        ownerA = _ownerA;
        ownerB = _ownerB;
    }

    function swap() public {
        require(
            msg.sender == ownerA || msg.sender == ownerB,
            "u cant participate"
        );
        require(
            tokenA.allowance(ownerA, address(this)) >= amntA_toSwap,
            "not enough tokenA"
        );
        require(
            tokenB.allowance(ownerB, address(this)) >= amntB_toSwap,
            "not enough tokenB"
        );
        safeSwap(tokenA, ownerA, ownerB, amntA_toSwap);
        safeSwap(tokenB, ownerB, ownerA, amntB_toSwap);
    }

    function safeSwap(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}
