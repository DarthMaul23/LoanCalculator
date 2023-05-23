import SwiftUI
import Combine

struct ContentView: View {
    @State private var tabSelection = 0
    @State private var cenaNemovitosti: Double = 300000
    @State private var vyseUveru: Double = 0
    @State private var years = 5
    @State private var fixace = 1
    @State private var lvt: Double = 0
    @State private var selectedYears = 5
    @State private var isShowingPicker = false
    @State private var cancellables = Set<AnyCancellable>()
    
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
                    calculateMortgage { result in
                        switch result {
                        case .success(let mortgagePayment):
                            print("Mortgage Payment: \(mortgagePayment)")
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
            LoanTerm: selectedYears,
            InterestRate: 3.71
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
    
    struct MortgageResult: Codable {
        let mortgagePayment: Double
    }
}
