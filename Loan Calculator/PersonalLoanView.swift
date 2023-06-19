import SwiftUI

struct PersonalLoanView: View {
    @State private var personalLoan: Double = 300000
    @State private var personalLoanTotal: Double = 300000
    @State private var vyseUveru2: Double = 0
    @State private var selectedMonths = 5
    @State private var loanInterestRate: Double = 1.0
    @State private var interestRate: Double = 1.0
    @State private var interestRateString: String = "1.0"
    
    @State private var isShowingPicker = false
    @State private var mortgageDetailsList = [MortgageDetails]()
    
    @State private var mortgagePaymentDetailsWithBanks: [MortgagePaymentWithBankDetails] = []
    @State private var isShowingModal = false
    
    let formatter = CustomFormatter()
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 0) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(.leading, 0)
                        .padding(.top, -40)
                        .foregroundColor(.blue)
                }
            }
            VStack(alignment: .leading) {
                Text("Loan:")
                TextField("Enter value", text: Binding(
                    get: {
                        formatter.formatNumberString(String(format: "%.0f", personalLoan))
                    },
                    set: { newValue in
                        let sanitizedValue = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        if let value = Double(sanitizedValue) {
                            personalLoan = value
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                Slider(value: $personalLoan, in: 0...2500000, step: 1000, minimumValueLabel: Text("$ 0 "), maximumValueLabel:  Text(formatter.formatNumberString("$ \(Int(2500000))")+"")) {
                    Text("Mortgage")
                }
            }.padding(.top, 15)
            
            VStack(alignment: .leading) {
                Text("Loan duration:")
                HStack{
                    TextField("Enter value", text: Binding(
                        get: { String(selectedMonths) },
                        set: { newValue in
                            if let value = Int(newValue) {
                                selectedMonths = value
                            }
                        }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .onTapGesture {
                        isShowingPicker = true
                    }
                    .sheet(isPresented: $isShowingPicker) {
                        VStack {
                            Text("Loan length")
                            HStack{
                                Picker(selection: $selectedMonths, label: Text("Loan length:")) {
                                    ForEach(2...96, id: \.self) { month in
                                        Text("\(month)")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.4)
                            }
                            Text("months")
                            Button("Done") {
                                isShowingPicker = false
                            }
                            .padding()
                        }
                    }
                    Text("Months")
                }
            }
            .padding(.top, 15)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Interest Rate %:")
                    VStack {
                        TextField("Enter value", text: Binding(
                            get: {
                                formatter.formatNumberString(String(format: "%.2f", loanInterestRate))
                            },
                            set: { newValue in
                                let sanitizedValue = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                                if let value = Double(sanitizedValue) {
                                    loanInterestRate = value/100
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        
                        Slider(value: $loanInterestRate, in: 0...30, step: 0.25, minimumValueLabel: Text("% \(Int(0))"), maximumValueLabel: Text("% \(Int(30))")) {
                            Text("Property value")
                        }
                    }
                    .padding(.top, 15)
                }
            }
            Button(action: {
                calculateLoan(
                    personalLoan: personalLoan,
                    selectedMonths: selectedMonths,
                    loanInterestRate: loanInterestRate,
                    personalLoanTotal: &personalLoanTotal
                ) { result in
                    switch result {
                    case .success(let mortgageDetailsList):
                        DispatchQueue.main.async {
                            self.mortgageDetailsList = mortgageDetailsList // Assuming the result is an array of MortgageDetails objects
                            isShowingModal = true
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }) {
                Text("Calculate")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 15)
        }
        .padding()
        .padding(.top, 50)
        .padding()
        .sheet(isPresented: $isShowingModal) {
            if mortgageDetailsList.count > 0 {
                TabView {
                    
                    let _monthlyPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru2, interestRate: loanInterestRate, loanDurationInMonths: selectedMonths)/Double(selectedMonths)
                    
                    let _totalPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru2, interestRate: loanInterestRate, loanDurationInMonths: selectedMonths)
                    
                    let dataPoints: [DataPoint] = [
                                           DataPoint(value: _totalPayment-vyseUveru2, label: "Úrok"),
                                           DataPoint(value: vyseUveru2, label: "Úvěr")
                                       ]
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
                                            Text("Interest Rate: \(interestRate, specifier: "%.2f")%")
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
            }
        }
    }
}

struct PersonalLoanView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalLoanView()
    }
}
