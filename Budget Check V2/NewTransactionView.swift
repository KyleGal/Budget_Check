//
//  NewTransactionView.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/12/23.
//

import SwiftUI

struct NewTransactionView: View {
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    @State private var date = Date()
    @State private var amount: Double = .zero
    @State private var isExpense: Bool = true
    
    @State private var institution: String = ""
    @State private var account: String = ""
    @State private var type: TransactionType.RawValue = ""
    @State private var merchant: String = ""
    
    @State private var categoryId: Int = .zero
    @State private var category: String = ""
    
    var body: some View {
        NavigationStack{
                VStack (spacing: 20) {
                    // amount
                    TextField("$0.00", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .font(.largeTitle)
                    // automatic date for today, but is changeable (date)
                    DatePicker ("Date of Transaction", selection: $date, in: ...Date(), displayedComponents: [.date])
                        .labelsHidden()
                    // income or expense (isExpense)
                    Picker ("Expense", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }.pickerStyle(.segmented)
                    
                    VStack (spacing: 30) {
                        // payment type (type)
                        Section {
                            VStack(alignment: .leading, spacing: 2) {
                                Picker ("Payment Type", selection: $type) {
                                    Text("Cash").tag("cash")
                                    Text("Debit").tag("debit")
                                    Text("Credit").tag("credit")
                                }.pickerStyle(.navigationLink)
                            }
                        }
                        
                        // what institution the card was from (institution)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Bank")
                            TextField("Discover, Chase, etc..", text: $institution)
                            Divider()
                        }
                        
                        // what card was used (Account)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Card")
                            TextField("Discover Credit Card, Chase Debit Card, etc..", text: $account)
                            Divider()
                        }
                        
                        // category which will be associated with categoryId
                        Section {
                            VStack(alignment: .leading, spacing: 1) {
                                Picker ("Category", selection: $categoryId) {
                                    Text("Income").tag(1)
                                    Text("Entertainment").tag(2)
                                    Text("Food & Dining").tag(3)
                                    Text("Shopping").tag(4)
                                    Text("Auto & Transport").tag(5)
                                    Text("Bills & Utilities").tag(6)
                                    Text("Groceries").tag(7)
                                    Text("Transfer").tag(8)
                                    Text("Credit Card Payment").tag(9)
                                }
                                .pickerStyle(.navigationLink)
                            }
                            
//                            // category name
//                            switch categoryId {
//                            case 1:
//                                category = "Income"
//                            case 2:
//                                category = "Entertainment"
//                            case 3:
//                                category = "Food & Dining"
//                            case 4:
//                                category = "Shopping"
//                            case 5:
//                                category = "Auto & Transport"
//                            case 6:
//                                category = "Bills & Utilities"
//                            case 7:
//                                category = "Groceries"
//                            case 8:
//                                category = "Transfer"
//                            case 9:
//                                category = "Credit Card Payment"
//                            }
                        }
                        
                        // description (merchant)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Description")
                            TextField("Description..", text: $merchant)
                            Divider()
                        }
                        
                        
                    }
                    
                    // Done button
                        // isPending = false; isTransfer = false; isEdited = true
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Done")
                            Spacer()
                        }
                    })
                    
                }
                .padding()
            }
    }
}

struct NewTransactionView_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        NewTransactionView()
            .environmentObject(transactionListVM)
        
        NewTransactionView()
            .environmentObject(transactionListVM)
            .preferredColorScheme(.dark)
    }
}
