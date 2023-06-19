import SwiftUI

struct PersonalLoanCalculationView: View {
    @Binding var isShowingModal2: Bool
    var mortgageDetailsList: [MortgageDetails]
    var vyseUveru2: Double
    var selectedMonths: Int
    var loanInterestRate: Double
    
    let formatter = CustomFormatter()
    
    var body: some View {
        TabView {
            // First Tab: Chart
            VStack {
                Text("Calculation Detail")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                Section {
                    PieChartWrapper(dataPoints: dataPoints)
                        .frame(width: 370, height: 250)
                        .padding(.top, -20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Payment: \(_monthlyPayment, specifier: "%.2f")")
                    Text("Loan Amount: \(vyseUveru2, specifier: "%.2f")")
                    Text("Total Paid Amount: \(_totalPayment, specifier: "%.2f")")
                    Text("Interest Rate: \(loanInterestRate, specifier: "%.2f")%")
                    Text("Interest Paid: \(round(_totalPayment-vyseUveru2), specifier: "%.2f")")
                    Text("Duration: \(selectedMonths) years")
                }
                .font(.subheadline)
                .padding(.top, 20)
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
                    .frame(height: 250)
                
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
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Payments")
            }
        }
        .onDisappear {
            self.isShowingModal2 = false
        }
    }
    
    private var _monthlyPayment: Double {
        calculateTotalLoanPayment(loanAmount: vyseUveru2, interestRate: loanInterestRate, loanDurationInMonths: selectedMonths) / Double(selectedMonths)
    }
    
    private var _totalPayment: Double {
        calculateTotalLoanPayment(loanAmount: vyseUveru2, interestRate: loanInterestRate, loanDurationInMonths: selectedMonths)
    }
    
    private var dataPoints: [DataPoint] {
        [
            DataPoint(value: _totalPayment - vyseUveru2, label: "Úrok"),
            DataPoint(value: vyseUveru2, label: "Úvěr")
        ]
    }
}

struct PersonalLoanCalculationView_Previews: PreviewProvider {
    static var previews: some View {
    PersonalLoanCalculationView(isShowingModal2: .constant(true), mortgageDetailsList: [], vyseUveru2: 150000, selectedMonths: 12, loanInterestRate: 2.7)
    }
}
