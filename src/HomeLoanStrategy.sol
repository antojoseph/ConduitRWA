// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/ReentrancyGuard.sol";

contract HomeLoanStrategy is ReentrancyGuard {
    uint256 public interestRate;  // Annual interest rate in basis points (e.g., 500 for 5%)
    address public sDAIAddress;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public depositTimestamps;
    mapping(address => uint256) public homeLoans;
    mapping(address => uint256) public homeLoanTimestamps;
    address[] public loanAddresses;


    constructor(uint256 _interestRate, address _sDAIAddress) {
        require(_interestRate > 0 && _interestRate <= 3000, "Interest rate should be between 0 and 30%");
        interestRate = _interestRate;
        sDAIAddress = _sDAIAddress;
    }

    function depositIntoStrategy(address token, uint256 amount, address sender) external {
        require(token == sDAIAddress, "Token is not sDAI");
        require(amount > 0, "Deposit amount should be greater than 0");

        require(IERC20(token).transferFrom(sender, address(this), amount), "Transfer failed");
        deposits[sender] += amount;
        depositTimestamps[sender] = block.timestamp;  // Store the timestamp of the deposit
    }

    function withdrawal(address asset, uint256 amount, address sender) external nonReentrant returns(uint256) {
        require(asset == sDAIAddress, "Asset is not sDAI");
        require(amount > 0 && amount <= deposits[sender], "Invalid withdrawal amount");

        uint256 bonus = (deposits[sender] * 2) / 100;  // Calculate 2% of the deposited amount
        uint256 totalWithdrawalAmount = amount + bonus;  // Total amount to be withdrawn
        
        // require(totalWithdrawalAmount <= deposits[sender], "Withdrawal exceeds deposit balance");
        
        deposits[sender] -= amount;  // Update the deposit balance

        // Transfer the total withdrawal amount to the depositor
        require(IERC20(asset).transfer(sender, totalWithdrawalAmount), "Transfer failed");

        return amount;
    }

    function newHomeLoan(address loanAddress, uint256 loanValue) external {
        require(loanAddress != address(0), "Invalid address");
        require(loanValue > 0, "Loan value should be greater than 0");
        homeLoans[loanAddress] = loanValue;
        homeLoanTimestamps[loanAddress] = block.timestamp;  // Store the timestamp of the loan
        loanAddresses.push(loanAddress);
    }

    function makePaymentForLoan(address loanAddress, uint256 payment) external returns (uint256) {
        require(loanAddress != address(0), "Invalid loan address");
        require(payment > 0, "Payment amount should be greater than 0");
        require(homeLoans[loanAddress] >= payment, "Payment exceeds outstanding loan balance");

        uint256 timeElapsed = block.timestamp - homeLoanTimestamps[loanAddress];  // Time elapsed in seconds
        uint256 timeElapsedInYears = timeElapsed / (365 days);

        uint256 interestAccrued = (homeLoans[loanAddress] * interestRate * timeElapsedInYears) / 10000;  // Calculate interest

        uint256 newPrincipal;
        if (payment >= interestAccrued) {
            uint256 principalPayment = payment - interestAccrued;  // Remaining payment after covering interest
            newPrincipal = homeLoans[loanAddress] - principalPayment;  // Reduce principal by payment amount
        } else {
            interestAccrued -= payment;  // Reduce interest accrued by payment amount if payment < interestAccrued
            newPrincipal = homeLoans[loanAddress] + interestAccrued;  // Increase principal if payment doesn't cover interest
        }

        homeLoans[loanAddress] = newPrincipal;  // Update the principal
        homeLoanTimestamps[loanAddress] = block.timestamp;  // Update the timestamp to the current block timestamp

        // Transfer the payment amount from the payer to the contract
        require(IERC20(sDAIAddress).transferFrom(msg.sender, address(this), payment), "Transfer failed");

        return newPrincipal;
    }

    function maxValueOfLoan(address asset) external view returns (uint256 maxValue) {
        require(asset == sDAIAddress, "Asset is not sDAI");
        uint256 totalValue;
        for (uint256 i = 0; i < loanAddresses.length; i++) {
            totalValue += homeLoans[loanAddresses[i]];
        }
        maxValue = totalValue / 100;
        return maxValue;
    }

    function maxWithdraw(address asset) external view returns (uint256 maxValue) {
        require(asset == sDAIAddress, "Asset is not sDAI");
        maxValue = deposits[msg.sender];  // The maximum withdrawable amount is the balance of the depositor
        return maxValue;
    }

}
