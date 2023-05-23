//
//  Formater.swift
//  Loan Calculator
//
//  Created by František Moucha on 23.05.2023.
//

import Foundation

class CustomFormatter {
    
    func formatNumber(_ income: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formattedIncome = formatter.string(from: NSNumber(value: income)) {
            return formattedIncome
        } else {
            return ""
        }
    }
    
    func formatNumberString(_ income: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        let sanitizedIncome = income.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let incomeValue = Int(sanitizedIncome),
           let formattedIncome = formatter.string(from: NSNumber(value: incomeValue)) {
            return formattedIncome
        } else {
            return ""
        }
    }
    
}
