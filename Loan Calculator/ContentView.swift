import SwiftUI
import Combine
import Charts

struct ContentView: View {
    @State private var tabSelection = 0
    @State private var cenaNemovitosti: Double = 300000
    @State private var personalLoan: Double = 300000
    @State private var vyseUveru: Double = 0
    @State private var vyseUveru2: Double = 0
    @State private var years = 30
    @State private var fixace = 1
    @State private var lvt: Double = 0
    @State private var interestRate: Double = 1.0
    @State private var interestRateString: String = "1.0"
    
    @State private var loanInterestRate: Double = 1.0
    @State private var loanInterestRateString: String = "1.0"
    
    @State private var selectedYears = 30
    @State private var selectedMonths = 5
    @State private var isShowingPicker = false
    @State private var cancellables = Set<AnyCancellable>()
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
        TabView(selection: $tabSelection) {
            // First Tab - User Inputs
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
                    Text("LVT: \(String(format: "%.0f", lvt))%")
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
                                Text("let")
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
                /*
                 HStack {
                 VStack {
                 Text("Interest Rate:")
                 TextField("Interest Rate", text: Binding<String>(
                 get: { "\(interestRate)" },
                 set: { interestRate = Double($0) ?? 0 }
                 ))
                 .keyboardType(.decimalPad)
                 .foregroundColor(.blue)
                 .frame(maxWidth: .infinity)
                 }
                 }
                 */
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Interest Rate %:")
                        HStack {
                            TextField("Enter value", text: $interestRateString)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            
                        }
                        .padding(.top, 15)
                    }
                    .onReceive(Just(interestRateString)) { value in
                        if let decimalValue = Decimal(string: value) {
                            interestRate = NSDecimalNumber(decimal: decimalValue).doubleValue
                        }
                    }
                }
                Button(action: {
                    calculateMortgage { result in
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
                if (mortgageDetailsList.count>0){
                    let dataPoints: [DataPoint] = [
                        DataPoint(value: vyseUveru - mortgageDetailsList[mortgageDetailsList.count - 1].alreadyPaid, label: "Úrok"),
                        DataPoint(value: vyseUveru, label: "Úvěr")
                    ]
                    
                    VStack {
                        VStack {
                            Text("Calculation Detail")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity)
                            
                            Section() {
                                PieChartWrapper(dataPoints: dataPoints)
                                    .frame(width: 250, height: 250)
                                    .padding(.top, -20)
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
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
                
            }
            
            .tabItem {
                Image(systemName: "house.fill")
                Text("Mortgage")
            }
            .tag(0)
            
            // Second Tab - Calculation Details
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
                /*
                 HStack {
                 VStack {
                 Text("Interest Rate:")
                 TextField("Interest Rate", text: Binding<String>(
                 get: { "\(interestRate)" },
                 set: { interestRate = Double($0) ?? 0 }
                 ))
                 .keyboardType(.decimalPad)
                 .foregroundColor(.blue)
                 .frame(maxWidth: .infinity)
                 }
                 }
                 */
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Interest Rate %:")
                        HStack {
                            TextField("Enter value", text: $loanInterestRateString)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            
                        }
                        .padding(.top, 15)
                    }
                    .onReceive(Just(loanInterestRateString)) { value in
                        if let decimalValue = Decimal(string: value) {
                            interestRate = NSDecimalNumber(decimal: decimalValue).doubleValue
                        }
                    }
                }
                Button(action: {
                    calculateLoan { result in
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
                if (mortgageDetailsList.count>0){
                    let dataPoints: [DataPoint] = [
                        DataPoint(value: mortgageDetailsList[mortgageDetailsList.count - 1].alreadyPaid - vyseUveru, label: "Úrok"),
                        DataPoint(value: vyseUveru, label: "Úvěr")
                    ]
                    
                    VStack {
                        VStack {
                            Text("Calculation Detail")
                                .font(.title)
                                .padding()
                                .frame(maxWidth: .infinity)
                            
                            Section() {
                                PieChartWrapper(dataPoints: dataPoints)
                                    .frame(width: 250, height: 250)
                                    .padding(.top, -20)
                            }
                        }
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    List {
                        Section(header: Text("Loan Details")) {
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
                
            }
            .padding()
            .tabItem {
                Image(systemName: "person.fill")
                Text("Personal loan")
            }
            .tag(1)
            
            // Third Tab - Data Table
            VStack {
                // Add your table components here
                Text("Settings")
            }
            .padding()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
    }
    
    func getMortgageDetail(){
        
    }
    
    func calculateMortgage(completion: @escaping (Result<[MortgageDetails], Error>) -> Void) {
        let input = MortgageInput(
            PropertyValue: cenaNemovitosti,
            LoanAmount: vyseUveru,
            LoanTerm: selectedYears,
            InterestRate: interestRate
        )
        print(interestRate)
        let loanAmount = input.LoanAmount
        let interestRate = input.InterestRate
        let loanTerm = input.LoanTerm
        
        let numberOfPayments = loanTerm * 12
        
        var mortgageDetailsList = [MortgageDetails]() // Initialize an empty array
        
        var remainingBalance = loanAmount
        let monthlyInterestRate = interestRate / 100
        let monthlyPayment = loanAmount * (monthlyInterestRate / (1 - pow(1 + monthlyInterestRate, -Double(numberOfPayments))))
        
        for month in 1...numberOfPayments {
            let interestPayment = remainingBalance * monthlyInterestRate / 12
            let principalPayment = monthlyPayment - interestPayment
            
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
        
        completion(.success(mortgageDetailsList)) // Return the array of MortgageDetails objects
    }
    
    func calculateLoan(completion: @escaping (Result<[MortgageDetails], Error>) -> Void) {
        
        let input = MortgageInput(
            PropertyValue: cenaNemovitosti,
            LoanAmount: personalLoan,
            LoanTerm: selectedMonths,
            InterestRate: interestRate
        )
        
        let loanAmount = input.LoanAmount
        let interestRate = input.InterestRate
        let loanTerm = input.LoanTerm
        
        let numberOfPayments = loanTerm
        
        var mortgageDetailsList = [MortgageDetails]() // Initialize an empty array
        
        var remainingBalance = loanAmount
        let monthlyInterestRate = interestRate / 100
        let monthlyPayment = loanAmount * (monthlyInterestRate / (1 - pow(1 + monthlyInterestRate, -Double(numberOfPayments))))
        
        for month in 1...numberOfPayments {
            let interestPayment = remainingBalance * monthlyInterestRate / 12
            let principalPayment = monthlyPayment - interestPayment
            
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
        
        completion(.success(mortgageDetailsList)) // Return the array of MortgageDetails objects
        
    }
    
    func calculateMortgagePaymentWithBanks(completion: @escaping (Result<[MortgagePaymentWithBankDetails], Error>) -> Void) {
        let input = LoanInput(
            LoanAmount: vyseUveru,
            LoanTerm: selectedYears,
            InterestRate: interestRate
        )
    }
    
    struct DataPoint {
        let value: Double
        let label: String
    }
    
    struct PieChartWrapper: UIViewRepresentable {
        let dataPoints: [DataPoint]
        
        func makeUIView(context: Context) -> PieChartView {
            let chartView = PieChartView()
            return chartView
        }
        
        func updateUIView(_ uiView: PieChartView, context: Context) {
            var entries: [ChartDataEntry] = []
            var colors: [NSUIColor] = [.green,.orange]
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = "$"
            numberFormatter.maximumFractionDigits = 2
            
            for (index, dataPoint) in dataPoints.enumerated() {
                let formattedValue = numberFormatter.string(from: NSNumber(value: round(dataPoint.value)))
                let entry = PieChartDataEntry(value: round(dataPoint.value), label: formattedValue)
                entries.append(entry)
            }
            
            let dataSet = PieChartDataSet(entries: entries, label: "")
            dataSet.colors = colors // Set the colors for the data set
            dataSet.selectionShift = 0 // Set the selection shift to 0
            dataSet.valueFont = UIFont.boldSystemFont(ofSize: 18) // Set the value label font to bold
            dataSet.entryLabelFont = UIFont.boldSystemFont(ofSize: 18)
            
            let chartData = PieChartData(dataSet: dataSet)
            
            uiView.data = chartData
            uiView.holeColor = .blue
            uiView.notifyDataSetChanged()
        }
        
        typealias UIViewType = PieChartView
    }
    
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
    
    struct BankListView: View {
        @State private var bankDetails: [MortgagePaymentWithBankDetails] = []
        @State private var showModal: Bool = false
        @State private var selectedBank: MortgagePaymentWithBankDetails?
        
        var body: some View {
            List(bankDetails, id: \.bank.name) { bankDetail in
                Button(action: {
                    selectedBank = bankDetail
                    showModal = true
                }) {
                    VStack(alignment: .leading) {
                        Text(bankDetail.bank.name)
                            .font(.headline)
                        Text("Total Payment: \(bankDetail.totalPayment)")
                            .font(.subheadline)
                        Text("Interest Rate: \(bankDetail.bank.interestRate)%")
                            .font(.subheadline)
                        Text("Monthly Payment: \(bankDetail.monthlyPayment)")
                            .font(.subheadline)
                    }
                }
            }
            .sheet(isPresented: $showModal) {
                if let selectedBank = selectedBank {
                    BankDetailView(bankDetail: selectedBank)
                }
            }
            .onAppear {
                fetchBankDetails()
            }
        }
        
        struct BankDetailView: View {
            let bankDetail: MortgagePaymentWithBankDetails
            
            var body: some View {
                VStack(alignment: .leading) {
                    Text(bankDetail.bank.name)
                        .font(.title)
                        .padding(.bottom, 10)
                    Text("Interest Rate: \(bankDetail.bank.interestRate)%")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    Text("Loan Amount: \(bankDetail.loanAmount)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    Text("Loan Term: \(bankDetail.loanTerm) years")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    Text("Total Payment: \(bankDetail.totalPayment)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    Text("Monthly Payment: \(bankDetail.monthlyPayment)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    Text("Overpayment: \(bankDetail.overPayment)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                .padding()
            }
        }
        
        func fetchBankDetails() {
            // Perform the API request to fetch bank details
            // Replace "YOUR_API_ENDPOINT" with the actual endpoint URL
            guard let url = URL(string: "YOUR_API_ENDPOINT/mortgage-payment-with-banks") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("Empty response data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode([MortgagePaymentWithBankDetails].self, from: data)
                    DispatchQueue.main.async {
                        self.bankDetails = result
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }.resume()
        }
    }
    
    // Custom modifier to restrict input to numeric values
    struct NumericKeyboardModifier: ViewModifier {
        @Binding var text: String
        
        init(_ text: Binding<String>) {
            self._text = text
        }
        
        func body(content: Content) -> some View {
            content
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { notification in
                    if let textField = notification.object as? UITextField {
                        let filtered = textField.text?.filter { "0123456789".contains($0) }
                        if filtered != textField.text {
                            textField.text = filtered
                        }
                        self.text = textField.text ?? ""
                    }
                }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
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
}
