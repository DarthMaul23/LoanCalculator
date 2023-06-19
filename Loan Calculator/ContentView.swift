import SwiftUI
import Combine
import Charts

struct ContentView: View {
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            // First Tab - User Inputs
            MortgageView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Mortgage")
            }
            .tag(0)
            
            // Second Tab - Calculation Details
            PersonalLoanView()
            .tabItem {
                Image(systemName: "person.fill")
                Text("Personal loan")
            }
            .tag(1)
            
            // Third Tab - Data Table
            DataTableView()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
    }
}
