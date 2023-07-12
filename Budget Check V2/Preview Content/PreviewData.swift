//
//  PreviewData.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import Foundation

var transactionPreviewData = Transaction(id: 1, date: "01/24/2022", institution: "Discover", account: "Visa Discover Credit", merchant: "McDonalds", amount: 5.39, type: "debit", categoryId: 801, category: "Food", isPending: false, isTransfer: false, isExpense: true, isEdited: false)

var transactionListPreviewData = [Transaction](repeating: transactionPreviewData, count: 10)
