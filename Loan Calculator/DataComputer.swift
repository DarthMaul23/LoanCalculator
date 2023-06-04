//
//  DataComputer.swift
//  Loan Calculator
//
//  Created by František Moucha on 04.06.2023.
//

import Foundation

func calculateLoanPayment(loanAmount: Double, interestRate: Double, loanDurationInMonths: Int) -> Double {
    let monthlyInterestRate = interestRate / 100 / 12
    let numerator = loanAmount * monthlyInterestRate * pow(1 + monthlyInterestRate, Double(loanDurationInMonths))
    let denominator = pow(1 + monthlyInterestRate, Double(loanDurationInMonths)) - 1
    let monthlyPayment = numerator / denominator
    return monthlyPayment
}

func calculateTotalLoanPayment(loanAmount: Double, interestRate: Double, loanDurationInMonths: Int) -> Double {
    let monthlyInterestRate = interestRate / 100 / 12
    let monthlyPayment = loanAmount * (monthlyInterestRate / (1 - pow(1 + monthlyInterestRate, -Double(loanDurationInMonths))))
    return monthlyPayment * Double(loanDurationInMonths)
}

func calculateMortgage(cenaNemovitosti: Double, vyseUveru: Double, selectedYears: Int, interestRate: Double, completion: @escaping (Result<[MortgageDetails], Error>) -> Void) {
    let input = MortgageInput(
        PropertyValue: cenaNemovitosti,
        LoanAmount: vyseUveru,
        LoanTerm: selectedYears,
        InterestRate: interestRate
    )
    
    let loanAmount = input.LoanAmount
    let interestRate = input.InterestRate
    let loanTerm = input.LoanTerm
    
    let numberOfPayments = loanTerm * 12
    
    var mortgageDetailsList = [MortgageDetails]() // Initialize an empty array
    
    var remainingBalance = loanAmount
    let monthlyInterestRate = interestRate / 100 / 12
    
    let monthlyPayment = calculateLoanPayment(loanAmount: loanAmount, interestRate: interestRate, loanDurationInMonths: numberOfPayments)
    
    for month in 1...numberOfPayments {
        let interestPayment = remainingBalance * monthlyInterestRate
        let principalPayment = monthlyPayment - interestPayment
        
        remainingBalance -= principalPayment
        
        let paymentDate = Date().addingTimeInterval(Double(month) * 30 * 24 * 60 * 60) // Assuming 30 days per month
        let alreadyPaid = loanAmount - remainingBalance
        let remainingToBePaid = remainingBalance + (remainingBalance * monthlyInterestRate * Double(numberOfPayments)) // Include the total interest in remaining balance
        let interestRateValue = interestRate
        
        let mortgageDetails = MortgageDetails(
            paymentDate: paymentDate,
            alreadyPaid: alreadyPaid,
            remainingToBePaid: remainingToBePaid,
            interestRateValue: interestRateValue,
            monthlyPayment: monthlyPayment
        )
        
        mortgageDetailsList.append(mortgageDetails) // Add the MortgageDetails object to the array
    }
    completion(.success(mortgageDetailsList)) // Return the array of MortgageDetails objects
}

func calculateLoan(personalLoan: Double, selectedMonths: Int, loanInterestRate: Double, personalLoanTotal: inout Double, completion: @escaping (Result<[MortgageDetails], Error>) -> Void) {
    let input = LoanInput(
        LoanAmount: personalLoan,
        LoanTerm: selectedMonths,
        InterestRate: loanInterestRate
    )
    
    let loanAmount = input.LoanAmount
    let interestRate = input.InterestRate
    let loanTerm = input.LoanTerm
    
    let numberOfPayments = loanTerm
    
    var mortgageDetailsList = [MortgageDetails]() // Initialize an empty array
    
    var remainingBalance = calculateTotalLoanPayment(loanAmount: personalLoan, interestRate: interestRate, loanDurationInMonths: selectedMonths)
    let monthlyInterestRate = interestRate / 100
    let monthlyPayment = loanAmount / Double(numberOfPayments)
    
    for month in 1...numberOfPayments {
        let interestPayment = remainingBalance * monthlyInterestRate
        let principalPayment = monthlyPayment
        
        remainingBalance -= principalPayment
        
        let paymentDate = Date().addingTimeInterval(Double(month) * 30 * 24 * 60 * 60) // Assuming 30 days per month
        let alreadyPaid = loanAmount - remainingBalance
        let remainingToBePaid = remainingBalance
        let interestRateValue = interestRate
        
        let mortgageDetails = MortgageDetails(
            paymentDate: paymentDate,
            alreadyPaid: alreadyPaid,
            remainingToBePaid: remainingToBePaid,
            interestRateValue: interestRateValue,
            monthlyPayment: monthlyPayment
        )
        
        mortgageDetailsList.append(mortgageDetails) // Add the MortgageDetails object to the array
    }
    
    personalLoanTotal = calculateLoanPayment(loanAmount: loanAmount, interestRate: interestRate, loanDurationInMonths: loanTerm)
    
    completion(.success(mortgageDetailsList)) // Return the array of MortgageDetails objects
}
