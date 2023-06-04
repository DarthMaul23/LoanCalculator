//
//  MortgageCalculationView.swift
//  Loan Calculator
//
//  Created by František Moucha on 04.06.2023.
//

import SwiftUI
import Foundation

let formatter = CustomFormatter()

struct MortgageCalculationView: View {
    @Binding var isShowingModal: Bool
    let mortgageDetailsList: [MortgageDetails]
    let vyseUveru: Double
    let interestRate: Double
    let selectedYears: Int
    
    var body: some View {
        if mortgageDetailsList.count > 0 {
            TabView {
                // First Tab: Chart
                VStack {
                    Text("Calculation Detail")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    Section {
                        let _monthlyPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru, interestRate: interestRate, loanDurationInMonths: (selectedYears*12))/(Double(selectedYears*12))
                        
                        let _totalPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru, interestRate: interestRate, loanDurationInMonths: selectedYears*12)
                        
                        let dataPoints: [DataPoint] = [
                            DataPoint(value: _totalPayment-vyseUveru, label: "Úrok"),
                            DataPoint(value: vyseUveru, label: "Úvěr")
                        ]
                        
                        PieChartWrapper(dataPoints: dataPoints)
                            .frame(width: 370, height: 250)
                            .padding(.top, -20)
                        
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Payment: \(_monthlyPayment, specifier: "%.2f")")
                            Text("Loan Amount: \(vyseUveru, specifier: "%.2f")")
                            Text("Total Paid Amount: \(_totalPayment, specifier: "%.2f")")
                            Text("Interest Rate: \(interestRate, specifier: "%.2f")%")
                            Text("Interest Paid: \(round(_totalPayment-vyseUveru), specifier: "%.2f")")
                            Text("Duration: \(selectedYears) years")
                        }
                        .font(.subheadline)
                        .padding(.top, 20)}
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Chart")
                }
                
                // Second Tab: List of Payments
                VStack {
                    let dataPointsSet1: [Double] = Array(Set(mortgageDetailsList.map { $0.alreadyPaid }))
                    let dataPointsSet2: [Double] = Array(Set(mortgageDetailsList.map { $0.remainingToBePaid }))
                    
                    LineChartView(dataSets: [dataPointsSet1, dataPointsSet2], lineColors: [.blue, .green])
                    
                    List {
                        Section(header: Text("Mortgage Details")) {
                            ForEach(mortgageDetailsList, id: \.paymentDate) { mortgageDetail in
                                VStack(alignment: .leading) {
                                    Text("Payment Date: \(formatter.formatDate(mortgageDetail.paymentDate))")
                                        .font(.headline)
                                    
                                    Group {
                                        Text("Already Paid: \(mortgageDetail.alreadyPaid, specifier: "%.2f")")
                                        Text("Remaining to be Paid: \(mortgageDetail.remainingToBePaid, specifier: "%.2f")")
                                        Text("Interest Rate: \(mortgageDetail.interestRateValue, specifier: "%.2f")%")
                                        Text("Monthly Payment: \(mortgageDetail.monthlyPayment ?? 0, specifier: "%.2f")")
                                    }
                                    .font(.subheadline)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }
            }
        }
    }
}
