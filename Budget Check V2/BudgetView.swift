//
//  BudgetView.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/9/23.
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    // 0 = Wants, 1 = Needs, 2 = Savings
    @State private var selectedPriority = 0
    
    var body: some View {
        VStack {
            
            VStack {
                Text("Reset Budget Nums:")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    // Action to perform when the button is tapped
                    print("Budget Nums Reset!")
                    transactionListVM.resetBudgetBuckets()
                }) {
                    Text("Click Me")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            
            HStack(spacing: 0) {
                // Header Title
                Text("Budget Priority")
                    .bold()
                Spacer()
                
                // database testing
//                Text(transactionListVM.moveTransactionsToDatabase())
                
                // Priority Picker
                Picker(selection: $selectedPriority, label: Text("Priority")) {
                    Text("Needs").tag(0)
                    Text("Wants").tag(1)
                    Text("Savings").tag(2)
                }
                .pickerStyle(.menu)
            }
            .padding(.top)
            
            // Top Priority
            VStack (spacing: 3) {
                if selectedPriority == 1 {  // Wants
                    Text("Wants")
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.background)
                        .frame(width: 150, height: 75)
                        .overlay {
                            Text(transactionListVM.showWants().formatted(.currency(code: "USD")))
                                .font(.title2)
                                .bold()
                                .padding()
                        }
                } else if selectedPriority == 0 {   // Needs
                    Text("Needs")
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.background)
                        .frame(width: 150, height: 75)
                        .overlay {
                            Text(transactionListVM.showNeeds().formatted(.currency(code: "USD")))
                                .font(.title2)
                                .bold()
                                .padding()
                        }
                } else {    // Savings
                    Text("Savings")
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.background)
                        .frame(width: 150, height: 75)
                        .overlay {
                            Text(transactionListVM.showSavings().formatted(.currency(code: "USD")))
                                .font(.title2)
                                .bold()
                                .padding()
                        }
                }
                
            }
            
            
            // Lower Priority: Needs & Savings
            HStack (spacing: 20) {
                VStack (spacing: 3) {
                    if selectedPriority == 1 {      // Wants -> Needs -> Savings
                        Text("Needs")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showNeeds().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    } else if  selectedPriority == 0 {       // Needs -> Savings -> Wants
                        Text("Savings")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showSavings().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    } else {        // Savings -> Wants -> Needs
                        Text("Wants")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showWants().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    }
                }
                    
                    
                VStack (spacing: 3) {
                    if selectedPriority == 1 {      // Wants -> Needs -> Savings
                        Text("Savings")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showSavings().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    } else if  selectedPriority == 0 {       // Needs -> Savings -> Wants
                        Text("Wants")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showWants().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    } else {        // Savings -> Wants -> Needs
                        Text("Needs")
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.background)
                            .frame(width: 150, height: 75)
                            .overlay {
                                Text(transactionListVM.showNeeds().formatted(.currency(code: "USD")))
                                    .font(.title2)
                                    .bold()
                                    .padding()
                            }
                    }
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.systemBackground)
        // creates the background shape of the VStack
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        // aplies a shadow to the background shape
        .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct BudgetView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        BudgetView()
            .environmentObject(transactionListVM)
        
        BudgetView()
            .environmentObject(transactionListVM)
            .preferredColorScheme(.dark)
    }
}
