//
//  ContentView.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    // data
    @EnvironmentObject var transactionListVM: TransactionListViewModel

    var body: some View {
        NavigationView {
            
            ScrollView {
                
                VStack (alignment: .leading, spacing: 23) {
                    // Title
                    Text("Overview")
                        .font(.title3)
                        .bold()
                    
                    // Line Chart
                        // data transactions amounts are accumulated using accumulateTransaction()
                    let data = transactionListVM.accumulateTransaction()
                    
                    if !data.isEmpty {
                        let totalExpenses = data.last?.1 ?? 0
                        CardView {
                            VStack(alignment: .leading) {
                                
                                ChartLabel(totalExpenses.formatted(.currency(code: "USD")), type: .title, format: "$%.02f")
                                
                                LineChart()
                            }
                            .background(Color.systemBackground)
                        }
                        .data(data)
                        .chartStyle(ChartStyle(backgroundColor: Color.systemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                        .frame(height: 300)
                    }
                    
                    // Needs, Wants, Savings
                    BudgetView()
                    
                    // Transaction List
                    RecentTransactionList()     // will crash preview because is child of contentView and is dependent on environment object
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // App Name
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Budget Check")
                        .font(.largeTitle)
                        .bold()
                }
                // Add Expense/Income Icon
                ToolbarItem {
                    Image(systemName: "plus.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                }
                // Notification Icon
                ToolbarItem {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                }
            }
            
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
    }
}


struct ContentView_Previews: PreviewProvider {
    // to prevent a crash, we pass the below instance of TransactionListViewModel into environmentObject
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        ContentView()
            .environmentObject(transactionListVM)
        
        ContentView()
            .environmentObject(transactionListVM)
            .preferredColorScheme(.dark)
    }
}
