//
//  RecentTransactionList.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import SwiftUI

struct RecentTransactionList: View {
    // @EnvironmentObject places the object into the environment
        // child views can easily gain access to this object without
    @EnvironmentObject var transactionListVM: TransactionListViewModel
    
    var body: some View {
        VStack {
            HStack {
                // Header Title
                Text("Recent Transactions")
                    .bold()
                Spacer()
                
                // Header Link
                NavigationLink {
                    TransactionList()
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color.text)
                }
            }
            .padding(.top)
            
            // Recent Transaction List
                // ForEach allows us to iterate and display each transaction in the transactionList
                // prefix shows the last 5 transactions
                // enumerated() will return a pair of counter and element of the collection
            ForEach(Array(transactionListVM.transactions.prefix(5).enumerated()), id: \.element) { index, transaction in
                TransactionRow(transaction: transaction)
                
                Divider()
                // removes bottom divider
                    .opacity(index == 4 ? 0 : 1)
            }
        }
        .padding()
        .background(Color.systemBackground)
        // creates the background shape of the VStack
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        // aplies a shadow to the background shape
        .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct RecentTransactionList_Previews: PreviewProvider {
    static let transactionListVM: TransactionListViewModel = {
        let transactionListVM = TransactionListViewModel()
        transactionListVM.transactions = transactionListPreviewData
        return transactionListVM
    }()
    
    static var previews: some View {
        RecentTransactionList()
            .environmentObject(transactionListVM)
        
        RecentTransactionList()
            .environmentObject(transactionListVM)
            .preferredColorScheme(.dark)
    }
}
