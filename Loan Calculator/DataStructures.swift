//
//  DataStructures.swift
//  Loan Calculator
//
//  Created by František Moucha on 04.06.2023.
//

import Foundation

struct MortgageDetails {
    let paymentDate: Date
    let alreadyPaid: Double
    let remainingToBePaid: Double
    let interestRateValue: Double
    let monthlyPayment: Double?
}

struct Bank: Codable {
    let name: String
    let interestRate: Double
    let loanFee: Double
    let sale: Double
    let insurance: Double
}

struct MortgagePaymentWithBankDetails: Codable {
    let bank: Bank
    let totalPayment: Double
    let monthlyPayment: Double
    let loanAmount: Double
    let loanTerm: Double
    let overPayment: Double
}

struct MortgageInput: Codable {
    let PropertyValue: Double
    let LoanAmount: Double
    let LoanTerm: Int
    let InterestRate: Double
}

struct LoanInput: Codable {
    let LoanAmount: Double
    let LoanTerm: Int
    let InterestRate: Double
}

struct MortgageResult: Codable {
    let mortgagePayment: Double
}

struct LoanResult: Codable {
    let mortgagePayment: Double
}

struct DataPoint {
    let value: Double
    let label: String
}
