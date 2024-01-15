// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {tokenSwap} from "../src/tokenSwap.sol";
import {mint} from "../src/mint.sol";

//token A - owner address(this)/deployer - bal:1000 tokenA initially
//tokenB - owner address(1) - bal: 1000 tokenB initially
//swap 100 tokenA for 300 tokenB
// Approve tokenA by  A: 200 tokenA
//Approve tokenB by B: 400 token B
// After swap A will have : 900tokenA and 300 tokenB and we will test that

contract CounterTest is Test {
    tokenSwap public swapp;
    mint public mntA;
    mint public mntB;

    function setUp() public {
        mntA = new mint("allen", "ALE");
        mntB = new mint("bob", "BOB");
        mntB.transfer(address(1), 1000 * 1e18); //transfer all token to address(1) making it the owner
        swapp = new tokenSwap(
            address(mntA),
            address(mntB),
            100 * 1e18,
            300 * 1e18,
            address(this),
            address(1)
        );
    }

    //test the if the balance of A after swap is correct
    function testSwap_BalA() public {
        mntA.approve(address(swapp), 200 * 1e18);
        vm.prank(address(1));
        mntB.approve(address(swapp), 400 * 1e18);
        swapp.swap();
        assertEq(mntA.balanceOf(address(this)), 900 * 1e18);
        assertEq(mntB.balanceOf(address(this)), 300 * 1e18);
    }

    function testSwap_balB() public {
        mntA.approve(address(swapp), 200 * 1e18);
        vm.prank(address(1));
        mntB.approve(address(swapp), 400 * 1e18);
        swapp.swap();
        assertEq(mntA.balanceOf(address(1)), 100 * 1e18);
        assertEq(mntB.balanceOf(address(1)), 700 * 1e18);
    }
    //both test passed - Swap function working properly
}

// console.log(address(this)); //0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
// console.log(address(mntA)); //0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
// console.log(mntA.totalSupply());
// console.log(address(mntB)); //0x2e234DAe75C793f67A35089C9d99245E1C58470b
// console.log(mntA.balanceOf(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496));
// console.log(mntB.balanceOf(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496));
// console.log(mntB.balanceOf(address(1)));
// console.log(address(swapp)); //0xF62849F9A0B5Bf2913b396098F7c7019b51A820a
