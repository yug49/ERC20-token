// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {DeployManualToken} from "../script/DeployManualToken.s.sol";
import {ManualToken} from "../src/ManualToken.sol";
import {console} from "../lib/forge-std/src/Script.sol";

contract ManualTokenTest is Test {
    ManualToken public manualToken;
    DeployManualToken public deployer;

    uint256 public constant INITIAL_BALANCE = 10 ether;
    uint256 public constant INITIAL_AMOUNT = 100 ether;
    uint256 public constant AMOUNT_ALLOWED = 5 ether;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TansferFromApproved(address indexed from, address indexed sender, address indexed to, uint256 value);
    event MintSuccesfull(address indexed to, uint256 value);
    event BurnSuccessfull(address indexed from, uint256 value);
    event MintSuccessfull(address indexed to, uint256 value);

    modifier fundBob() {
        vm.prank(msg.sender);
        manualToken.transfer(bob, INITIAL_BALANCE);
        _;
    }

    function setUp() public {
        deployer = new DeployManualToken();
        manualToken = deployer.run();
    }

    function testTotalSupply() public view {
        assert(manualToken.totalSupply() == INITIAL_AMOUNT);
    }

    function testBalanceMap() public fundBob {
        assert(manualToken.getBalance(msg.sender) == INITIAL_AMOUNT - INITIAL_BALANCE);
        assert(manualToken.getBalance(bob) == INITIAL_BALANCE);
    }

    function testTransfer() public {
        uint256 initialSenderBalance = manualToken.getBalance(msg.sender);
        uint256 initialAliceBalance = manualToken.getBalance(alice);
        vm.prank(msg.sender);
        manualToken.transfer(alice, INITIAL_BALANCE);
        assert(initialSenderBalance - INITIAL_BALANCE == manualToken.getBalance(msg.sender));
        assert(initialAliceBalance + INITIAL_BALANCE == manualToken.getBalance(alice));
    }

    function testTansferInvalidSenderReverts() public {
        vm.prank(address(0));
        vm.expectRevert(ManualToken.ManualToken__InvalidSender.selector);
        manualToken.transfer(bob, INITIAL_BALANCE);
    }

    function testTansferInvalidReceiverReverts() public {
        vm.prank(msg.sender);
        vm.expectRevert(ManualToken.ManualToken__InvalidReceiver.selector);
        manualToken.transfer(address(0), INITIAL_BALANCE);
    }

    function testTansferRevertsInsufficientBalance() public fundBob{
        vm.prank(bob);
        vm.expectRevert(ManualToken.ManualToken__InsufficientBalance.selector);
        manualToken.transfer(alice, 15 ether);
    }

    function testTransferEmitsTransfer() public{
        vm.prank(msg.sender);
        vm.expectEmit(true, true, false, true, address(manualToken));
        emit Transfer(msg.sender, alice, INITIAL_BALANCE);

        manualToken.transfer(alice, INITIAL_BALANCE);
    }


    function testAllowanceMap() public{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        assert(manualToken.getAllowances(msg.sender, bob) == AMOUNT_ALLOWED); 
    }

    function testAllowanceRevertInvalidSender() public {
        vm.prank(address(0));
        vm.expectRevert(ManualToken.ManualToken__InvalidSender.selector);
        manualToken.allowance(bob, INITIAL_BALANCE);
    }
    
    function testAllowanceRevertInvalidReceiver() public {
        vm.prank(msg.sender);
        vm.expectRevert(ManualToken.ManualToken__InvalidReceiver.selector);
        manualToken.allowance(address(0), INITIAL_BALANCE);
    }

    function testTransferFrom() public fundBob{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        vm.prank(bob);
        manualToken.transferFrom(msg.sender, alice, AMOUNT_ALLOWED - 1 ether);
        assert(manualToken.getBalance(msg.sender) == INITIAL_AMOUNT - INITIAL_BALANCE - AMOUNT_ALLOWED + 1 ether);
        assert(manualToken.getBalance(alice) == AMOUNT_ALLOWED - 1 ether);
    }

    function testTransferFromRevertInvalidSender() public fundBob{
        vm.prank(address(0));
        vm.expectRevert(ManualToken.ManualToken__InvalidSender.selector);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
    }

    function testTransferFromRevertInvalidReceiver() public fundBob{
        vm.prank(msg.sender);
        vm.expectRevert(ManualToken.ManualToken__InvalidReceiver.selector);
        manualToken.allowance(address(0), AMOUNT_ALLOWED);
    }

    function testTransferFromRevertDenied() public fundBob{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        vm.prank(bob);
        vm.expectRevert(ManualToken.ManualToken__SendersAllowanceDenied.selector);
        manualToken.transferFrom(msg.sender, alice, AMOUNT_ALLOWED + 1 ether);
        
    }

    function testTransferFromRevertsInsufficientBalance() public {
        vm.prank(bob);
        manualToken.allowance(alice, AMOUNT_ALLOWED);
        vm.prank(alice);
        vm.expectRevert(ManualToken.ManualToken__InsufficientBalance.selector);
        manualToken.transferFrom(bob, alice, AMOUNT_ALLOWED - 1 ether);
    }

    function testTransferFromEmitsTransfer() public fundBob{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        vm.prank(bob);
        vm.expectEmit(true,true,false, true, address(manualToken));
        emit Transfer(msg.sender, alice, AMOUNT_ALLOWED - 1 ether);
        manualToken.transferFrom(msg.sender, alice, AMOUNT_ALLOWED - 1 ether);
    }

    function testTransferApproved() public fundBob{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        vm.prank(bob);
        vm.expectEmit(true, true, true, true, address(manualToken));
        emit TansferFromApproved(msg.sender, bob, alice, AMOUNT_ALLOWED - 1 ether);
        manualToken.transferFrom(msg.sender, alice, AMOUNT_ALLOWED - 1 ether);
    }

    function testAllowanceUpdatesAllowances() public fundBob{
        vm.prank(msg.sender);
        manualToken.allowance(bob, AMOUNT_ALLOWED);
        vm.prank(bob);
        manualToken.transferFrom(msg.sender, alice, AMOUNT_ALLOWED - 1 ether);

        assert(manualToken.getAllowances(msg.sender, bob) == 1 ether);
    }

    
}
