import SwiftUI

struct MortgageView: View {
    @State private var cenaNemovitosti: Double = 300000
    @State private var vyseUveru: Double = 0
    @State private var years = 30
    @State private var fixace = 1
    @State private var lvt: Double = 0
    @State private var interestRate: Double = 1.0
    @State private var interestRateString: String = "1.0"
    
    @State private var selectedYears = 30
    @State private var isShowingPicker = false
    @State private var mortgageDetailsList = [MortgageDetails]()
    
    @State private var mortgagePaymentDetailsWithBanks: [MortgagePaymentWithBankDetails] = []
    @State private var isShowingModal = false
    
    let cenaNemovitostiRange = 30000...10000000
    let monthsRange = 5...30
    let fixaceOptions = [1, 3, 5, 7, 10]
    
    let yearRange = 1...35
    let monthRange = 0...11
    
    let _defaultLVT = 0.9
    
    let formatter = CustomFormatter()
    
    var body: some View {
        VStack {
            VStack{
                Image(systemName: "house.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.horizontal, 150)
                    .padding(.top, -80)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading) {
                Text("Property price:")
                TextField("Enter value", text: Binding(
                    get: {
                        formatter.formatNumber(cenaNemovitosti)
                    },
                    set: { newValue in
                        let sanitizedValue = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        if let incomeValue = Double(sanitizedValue) {
                            cenaNemovitosti = incomeValue
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                Slider(value: $cenaNemovitosti, in: 30000...35000000, step: 50000, minimumValueLabel: Text("$ \(Int(cenaNemovitostiRange.lowerBound))"), maximumValueLabel: Text(formatter.formatNumberString("$ 35000000")+"")) {
                    Text("Property value")
                }
                .onChange(of: cenaNemovitosti) { value in
                    vyseUveru = cenaNemovitosti * _defaultLVT
                    lvt = round((vyseUveru/cenaNemovitosti)*100)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Mortgage:")
                TextField("Enter value", text: Binding(
                    get: {
                        formatter.formatNumberString(String(format: "%.0f", vyseUveru))
                    },
                    set: { newValue in
                        let sanitizedValue = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        if let value = Double(sanitizedValue) {
                            vyseUveru = min(value, cenaNemovitosti * _defaultLVT)
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                Slider(value: $vyseUveru, in: 0...(cenaNemovitosti * _defaultLVT), step: 10000, minimumValueLabel: Text("$ 0 "), maximumValueLabel:  Text(formatter.formatNumberString("$ \(Int(cenaNemovitosti * _defaultLVT))")+"")) {
                    Text("Mortgage")
                }
                .onChange(of: vyseUveru) { value in
                    lvt = round((vyseUveru/cenaNemovitosti)*100)
                    if value > ((cenaNemovitosti * _defaultLVT) - 100000) {
                        vyseUveru = cenaNemovitosti * _defaultLVT
                    }
                }
                Text("LTV: \(String(format: "%.0f", lvt))%")
            }.padding(.top, 15)
            
            VStack(alignment: .leading) {
                Text("Mortgage duration:")
                HStack{
                    TextField("Enter value", text: Binding(
                        get: { String(selectedYears) },
                        set: { newValue in
                            if let value = Int(newValue) {
                                selectedYears = value
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
                            Text("Mortgage length")
                            HStack{
                                Picker(selection: $selectedYears, label: Text("Mortgage length:")) {
                                    ForEach(5...30, id: \.self) { year in
                                        Text("\(year)")
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.4)
                            }
                            Text("years")
                            Button("Done") {
                                isShowingPicker = false
                            }
                            .padding()
                        }
                    }
                    Text("Years")
                }
            }
            .padding(.top, 15)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Interest Rate %:")
                    VStack {
                        TextField("Enter value", text: Binding(
                            get: {
                                formatter.formatNumberString(String(format: "%.2f", interestRate))
                            },
                            set: { newValue in
                                let sanitizedValue = newValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                                if let value = Double(sanitizedValue) {
                                    interestRate = value/100
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        
                        Slider(value: $interestRate, in: 0...30, step: 0.25, minimumValueLabel: Text("% \(Int(0))"), maximumValueLabel: Text("% \(Int(30))")) {
                            Text("Property value")
                        }
                    }
                    .padding(.top, 15)
                }
            }
            Button(action: {
                calculateMortgage(
                    cenaNemovitosti: cenaNemovitosti,
                    vyseUveru: vyseUveru,
                    selectedYears: selectedYears,
                    interestRate: interestRate
                )  { result in
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
                    
                    let _monthlyPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru, interestRate: interestRate, loanDurationInMonths: (selectedYears*12))/(Double(selectedYears*12))
                    
                    let _totalPayment: Double = calculateTotalLoanPayment(loanAmount: vyseUveru, interestRate: interestRate, loanDurationInMonths: selectedYears*12)
                    
                    let dataPoints: [DataPoint] = [
                                           DataPoint(value: _totalPayment-vyseUveru, label: "Úrok"),
                                           DataPoint(value: vyseUveru, label: "Úvěr")
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
                            Text("Loan Amount: \(vyseUveru, specifier: "%.2f")")
                            Text("Total Paid Amount: \(_totalPayment, specifier: "%.2f")")
                            Text("Interest Rate: \(interestRate, specifier: "%.2f")%")
                            Text("Interest Paid: \(round(_totalPayment-vyseUveru), specifier: "%.2f")")
                            Text("Duration: \(selectedYears) years")
                        }
                        .font(.subheadline)
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .edgesIgnoringSafeArea(.all)
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Chart")
                    }
                    
                    // Second Tab: List of Payments
                    VStack {
                        let dataPointsSet1: [Double] = Array(Set(mortgageDetailsList.map { $0.alreadyPaid }))
                        let dataPointsSet2: [Double] = Array(Set(mortgageDetailsList.map { $0.remainingToBePaid }))

                        LineChartView(dataSets: [dataPointsSet1, dataPointsSet2], lineColors: [.purple, .green])
                            .frame(height: 350)
                        
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

struct MortgageView_Previews: PreviewProvider {
    static var previews: some View {
        MortgageView()
    }
}
