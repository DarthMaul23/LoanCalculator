import SwiftUI
import Combine

struct ContentView: View {
    @State private var tabSelection = 0
    @State private var cenaNemovitosti: Double = 300000
    @State private var vyseUveru: Double = 0
    @State private var years = 30
    @State private var fixace = 1
    @State private var lvt: Double = 0
    @State private var selectedYears = 30
    @State private var isShowingPicker = false
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var mortgagePaymentDetailsWithBanks: [MortgagePaymentWithBankDetails] = []
    @State private var isShowingModal = false
    
    let cenaNemovitostiRange = 300000...10000000
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
                VStack(alignment: .leading) {
                    Text("Cena nemovitosti:")
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
                    Slider(value: $cenaNemovitosti, in: 300000...10000000, step: 100000, minimumValueLabel: Text("\(Int(cenaNemovitostiRange.lowerBound)) Kč"), maximumValueLabel: Text(formatter.formatNumberString("\(Int(cenaNemovitostiRange.upperBound))")+" Kč")) {
                        Text("Cena nemovitosti")
                    }
                    .onChange(of: cenaNemovitosti) { value in
                        vyseUveru = cenaNemovitosti * _defaultLVT
                        lvt = round((vyseUveru/cenaNemovitosti)*100)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Výše úvěru:")
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
                    Slider(value: $vyseUveru, in: 0...(cenaNemovitosti * _defaultLVT), step: 100000, minimumValueLabel: Text("0 Kč"), maximumValueLabel:  Text(formatter.formatNumberString("\(Int(cenaNemovitosti * _defaultLVT))")+"Kč")) {
                        Text("Výše úvěru")
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
                    Text("Doba splácení:")
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
                                Text("Doba splácení:")
                                HStack{
                                    Picker(selection: $selectedYears, label: Text("Doba splácení")) {
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
                        Text("let")
                    }
                }
                .padding(.top, 15)
                
                HStack {
                    VStack {
                        Text("Fixace:")
                        Picker(selection: $fixace, label: Text("Fixace")) {
                            ForEach(fixaceOptions.indices, id: \.self) { index in
                                Text("\(fixaceOptions[index]) \(index == 0 ? "rok" : (index == 1 ? "roky" : "let"))")
                                    .foregroundColor(fixace == index ? .blue : .primary)
                            }
                        }
                        .pickerStyle(.inline)
                        .frame(maxWidth: .infinity)
                    }
                    
                }
                
                Button(action: {
                    calculateMortgagePaymentWithBanks { result in
                        switch result {
                        case .success(let paymentDetailsWithBanks):
                            mortgagePaymentDetailsWithBanks = paymentDetailsWithBanks
                            isShowingModal = true
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
                VStack {
                    Text("Nabídky")
                        .font(.title)
                        .padding()
                    
                    List(mortgagePaymentDetailsWithBanks, id: \.bank.name) { paymentWithBank in
                        VStack(alignment: .leading) {
                            Text(paymentWithBank.bank.name)
                                .font(.headline)
                            Text("Úrok: \(paymentWithBank.bank.interestRate, specifier: "%.2f") %")
                            Text("Hypotéka: \(paymentWithBank.loanAmount, specifier: "%.2f") Kč")
                            Text("Doba: \(paymentWithBank.loanTerm, specifier: "%.2f") Let")
                            Text("Měsíční splátka: \(paymentWithBank.monthlyPayment, specifier: "%.2f") Kč")
                            Text("Celková cena: \(paymentWithBank.totalPayment, specifier: "%.2f") Kč")
                            Text("Přeplaceno: \(paymentWithBank.overPayment, specifier: "%.2f") Kč")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                    }
                }
            }
            
            .tabItem {
                Image(systemName: "house.fill")
                Text("Hypoteční úvěr")
            }
            .tag(0)
            
            // Second Tab - Calculation Details
            VStack {
                // Add your calculation detail components here
                Text("Spotřebitelský úvěr")
            }
            .padding()
            .tabItem {
                Image(systemName: "person.fill")
                Text("Spotřebitelský úvěr")
            }
            .tag(1)
            
            // Third Tab - Data Table
            VStack {
                // Add your table components here
                Text("Nastavení")
            }
            .padding()
            .tabItem {
                Image(systemName: "gear")
                Text("Nastavení")
            }
            .tag(2)
        }
    }
    
    func calculateMortgage(completion: @escaping (Result<Double, Error>) -> Void) {
        let input = MortgageInput(
            PropertyValue: cenaNemovitosti,
            LoanAmount: vyseUveru,
            LoanTerm: selectedYears
        )
        
        guard let url = URL(string: "http://localhost:5114/api/mortgage") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            completion(.failure(NSError(domain: "Encoding error", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Empty response data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Double.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func calculateMortgagePaymentWithBanks(completion: @escaping (Result<[MortgagePaymentWithBankDetails], Error>) -> Void) {
        let input = MortgageInput(
            PropertyValue: cenaNemovitosti,
            LoanAmount: vyseUveru,
            LoanTerm: selectedYears
        )
        guard let url = URL(string: "http://localhost:5114/api/mortgage/mortgage-payment-with-banks") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            completion(.failure(NSError(domain: "Encoding error", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Empty response data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([MortgagePaymentWithBankDetails].self, from: data)
                print(result)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
    }
    
    struct MortgageResult: Codable {
        let mortgagePayment: Double
    }
}
