// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;
import { IArrangerConduit } from "../../src/interfaces/IArrangerConduit.sol";
import { HomeLoanProtocol }  from "../../src/HomeLoanProtocol.sol";
import { HomeLoanStrategy }  from "../../src/HomeLoanStrategy.sol";
import { console2 as console } from "../../lib/forge-std/src/console2.sol";
import { stdError }            from "../../lib/forge-std/src/StdError.sol";
import { Test }                from "../../lib/forge-std/src/Test.sol";
import { MockERC20 } from "../../lib/mock-erc20/src/MockERC20.sol";


interface StrategyManager{
    function depositIntoStrategy(address strategy,address token,uint256 amount) external view returns (uint256 shares);
}

contract HomeLoanProtocolTest is Test {

    address admin    = makeAddr("admin");
    address borrower = makeAddr("borrower");
    address lender1 = makeAddr("lender1");
    address lender2 = makeAddr("lender2");

    HomeLoanProtocol  homeLoanProtocolImplementation;
    HomeLoanStrategy  homeLoanStrategyImplementation;
    MockERC20 asset = new MockERC20("sDAI", "sDAI", 18);
    
    address attacker = address(0x7E3B29f2eaAFA9008a2C60a2e107a0E6487A7628);

    function setUp() public virtual {
        homeLoanStrategyImplementation = new HomeLoanStrategy(100, address(asset));
        homeLoanProtocolImplementation = new HomeLoanProtocol(address(homeLoanStrategyImplementation));
        asset.mint(address(lender1), 300 ether);
        asset.mint(address(lender2), 100 ether);
        asset.mint(address(borrower), 400 ether);
    }
    
     function test_conduit() public {
        
        console.log(address(homeLoanProtocolImplementation));

        console.log(asset.balanceOf(address(homeLoanStrategyImplementation)));
        vm.prank(lender1);
        asset.approve(address(homeLoanStrategyImplementation), 200);
        vm.prank(lender1);
        // vm.prank(lender1);
        homeLoanProtocolImplementation.deposit('0xilk', address(asset), 200);
        console.log("The Loan strategy balance", asset.balanceOf(address(homeLoanStrategyImplementation)));
    }
    

    function test_new_loan() public {
        // simulate a new loan which was granted and approved.
        console.log("New home loan created");
        asset.mint(address(homeLoanStrategyImplementation), 100 ether);
        console.log("The Loan strategy balance", asset.balanceOf(address(homeLoanStrategyImplementation)));
        homeLoanStrategyImplementation.newHomeLoan(address(borrower), 100 ether);
        console.log("home loan granted for:", asset.balanceOf(address(borrower)));
    }

    function test_new_loan_with_payment() public {
        // simulate a new loan which was granted and approved.
        vm.warp(1697838529);
        console.log("New home loan created");
        asset.mint(address(homeLoanStrategyImplementation), 100 ether);
        console.log("The Loan strategy balance", asset.balanceOf(address(homeLoanStrategyImplementation)));
        homeLoanStrategyImplementation.newHomeLoan(address(borrower), 100 ether);
        console.log("home loan granted for:", asset.balanceOf(address(borrower)));
        vm.warp(1697938529);
        vm.prank(address(borrower));
        asset.approve(address(homeLoanStrategyImplementation), 1 ether);
        vm.prank(address(borrower));
        uint256 newPrincipal = homeLoanStrategyImplementation.makePaymentForLoan(address(borrower), 1 ether);
        console.log("home loan payment received from borrower. New Principal value with interest: ", newPrincipal);
    }

    function test_new_loan_with_full_payment_and_withdrawal() public {
        // simulate a new loan which was granted and approved.
        vm.warp(1697838529);
        console.log("warp to 1697838529");
        console.log("New home loan created");
        vm.prank(lender1);
       // loan approved.
        asset.approve(address(homeLoanStrategyImplementation), 200 ether);
        vm.prank(lender1);
        homeLoanProtocolImplementation.deposit('0xilk', address(asset), 200 ether);
        
        console.log("The Loan strategy balance", asset.balanceOf(address(homeLoanStrategyImplementation)));
        vm.prank(borrower);
        homeLoanStrategyImplementation.newHomeLoan(address(borrower), 100 ether);
        console.log("home loan granted for:", asset.balanceOf(address(borrower)));

        vm.warp(1697938529);
        console.log("warp to 1697938529");
        vm.prank(address(borrower));
        asset.approve(address(homeLoanStrategyImplementation), 1 ether);
        vm.prank(address(borrower));
        uint256 newPrincipal = homeLoanStrategyImplementation.makePaymentForLoan(address(borrower), 1 ether);
        console.log("home loan payment received from borrower. New Principal value with interest: ", newPrincipal);

        vm.warp(1697988529);
        console.log("warp to 1697988529");
        vm.prank(address(borrower));
        asset.approve(address(homeLoanStrategyImplementation), 99 ether);
        vm.prank(address(borrower));
        uint256 newerPrincipal = homeLoanStrategyImplementation.makePaymentForLoan(address(borrower), 99 ether);
        console.log("home loan payment received from borrower. Newer Principal value with interest: ", newerPrincipal);
        console.log("Loan was given for 100000000000000000000 ether but in total return now was", asset.balanceOf(address(homeLoanStrategyImplementation)));

        console.log("Now withdrawing funds");
        vm.prank(lender1);
        homeLoanProtocolImplementation.withdraw("0xilk", address(asset), 200 ether);
    }

}