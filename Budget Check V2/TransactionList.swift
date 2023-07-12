//
//  TransactionList.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/8/23.
//

import SwiftUI

struct TransactionList: View {
    // able to get the entire transaction list
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack {
            List {
                // Transactions Grouped by Month
                ForEach(Array(transactionListVM.groupTransactionsByMonth()), id: \.key) {month, transactions in
                    Section {
                        // Transaction List
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    } header: {
                        // Month
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    static var previews: some View {
        Group {
            NavigationView {
                TransactionList()
            }
            
            NavigationView {
                TransactionList()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(transactionListVM)
    }
}
