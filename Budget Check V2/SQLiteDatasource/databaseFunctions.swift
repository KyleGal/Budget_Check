//
//  databaseFunctions.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 9/28/23.
//

import Foundation
import GRDB

// functions for databaseTransactionModel table
extension TransactionListViewModel {
    // READ
    func readTransaction(id: Int) -> DatabaseTransactionModel? {
        print("fetchingTransaction")
        var returnModel:DatabaseTransactionModel? = nil
        
        do {
            try database.reader.read { db in
                if let transaction = try DatabaseTransactionModel.fetchOne(db, sql:"SELECT * FROM DatabaseTransactionModel WHERE id = ?", arguments: [id]) {
                    let fetchedModel = DatabaseTransactionModel(id: transaction.id!, name: transaction.name, date: transaction.date, categoryID: transaction.categoryID, amount: transaction.amount, type: transaction.type, isExpense: transaction.isExpense)
                    
                    returnModel = fetchedModel
                }
            }
        } catch {
            print("\(error)")
        }
        
        print(returnModel?.amount as Any)
        print("fetchedTransaction")
        return returnModel
    }
    // UPDATE
    
    // INSERT
    func addTransaction(name: String, date: String, categoryID: Int, amount: Double, type:TransactionType.RawValue, isExpense: Bool) {
        print("addingTransaction")
        
        do {
            try database.writer.write { db in
                try DatabaseTransactionModel(id: nil, name: name, date: date, categoryID: categoryID, amount: amount, type: type, isExpense: isExpense).insert(db)
            }
        } catch {
            print("\(error)")
        }
        print("addTransactionComplete")
    }
    
    // DELETE
    func deleteTransaction (id: Int, categoryID: Int) {
        print("deletingTransaction")
        
        do {
            if let transaction = readTransaction(id: id) {
                try database.writer.write { db in
                    try DatabaseTransactionModel.deleteOne(db, key: ["id": transaction.id])
                    print("transactionDeleted")
                }
            }
        } catch {
            print("\(error)")
        }
    }
}



// functions for BudgetBuckets table
extension TransactionListViewModel {
    
    func accumulateIncome() -> Double {
        print("accumulateIncomeTransactions")
        
        var incomeSum: Double = .zero
        
        do {
            // read in the amounts from database
            try database.reader.read { db in
                let rows = try DatabaseTransactionModel.fetchCursor(db, sql: "SELECT amount FROM databaseTransactionModel")
                while let row = try rows.next() {
                    // Sum Income
                    if row.isExpense == false {
                        incomeSum += row.amount
                    }
                }
            }
        } catch {
            print("Error accumulating income: \(error)")
        }
        
        print("Income:", incomeSum.roundedTo2Digits())
        return incomeSum.roundedTo2Digits()
    }
    
    func accumulateExpenses() -> Double {
        print("accumulateExpensesTransactions")
        
        var expenseSum: Double = .zero
        
        do {
            // read in the amounts from database
            try database.reader.read { db in
                let rows = try DatabaseTransactionModel.fetchCursor(db, sql: "SELECT amount FROM databaseTransactionModel")
                while let row = try rows.next() {
                    // Sum Expenses
                    if row.isExpense == true {
                        expenseSum += row.amount
                    }
                }
            }
        } catch {
            print("Error accumulating income: \(error)")
        }
        
        print("Income:", expenseSum.roundedTo2Digits())
        return expenseSum.roundedTo2Digits()
    }
    
    // READ functions
    func showNeeds() -> Double {
        var amount:Double = 0
        do {
            
            // read database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs FROM BudgetBuckets") {
                    if let needs = rows["needs"] as? Double {
                        amount = needs
                        print("Needs Amount: ", amount)
                    }
                }
            }
        } catch {
            print("Show Needs Error: \(error)")
        }
        
        return amount.roundedTo2Digits()
    }
    
    func showWants() -> Double {
        var amount:Double = 0
        do {
            
            // read database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT wants FROM BudgetBuckets") {
                    if let wants = rows["wants"] as? Double {
                        amount = wants
                        print("Wants Amount: ", amount)
                    }
                }
            }
        } catch {
            print("Show Wants Error: \(error)")
        }
        
        return amount.roundedTo2Digits()
    }
    
    func showSavings() -> Double {
        var amount:Double = 0
        do {
            
            // read database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT savings FROM BudgetBuckets") {
                    if let savings = rows["savings"] as? Double {
                        amount = savings
                        print("Savings Amount: ", amount)
                    }
                }
            }
        } catch {
            print("Show Savings Error: \(error)")
        }
        
        return amount.roundedTo2Digits()
    }
    
    // WRITE functions
    func writeToBudgetBuckets(needs:Double, wants:Double, savings:Double) {
        
        do {
            try database.writer.write { db in
                try db.execute(
                    sql: "UPDATE BudgetBuckets SET needs = ?, wants = ?, savings = ?", arguments: [needs, wants, savings])
            }
        } catch {
            print("WriteNeeds Error: \(error)")
        }
    }
    
    
    func addToNeeds(income:Double) {
        do {
            var newNeeds:Double = 0
            
            var currWants:Double = 0
            var currSavings:Double = 0
            
            // read from database table "BudgetBuckets"
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let needs = rows["needs"] as? Double {
                        newNeeds = needs + income
                        print("NewNeeds Amount: ", newNeeds)
                        
                        currWants = rows["wants"]
                        currSavings = rows["savings"]
                    }
                }
            }
            writeToBudgetBuckets(needs: newNeeds, wants: currWants, savings: currSavings)
        } catch {
            print("AddNeeds Error: \(error)")
        }
    }
    
    func addToWants(income:Double) {
        do {
            var newWants:Double = 0
            
            var currNeeds:Double = 0
            var currSavings:Double = 0
            
            // read from database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let wants = rows["wants"] as? Double {
                        newWants = wants + income
                        print("NewWants Amount: ", newWants)
                        
                        currNeeds = rows["needs"]
                        currSavings = rows["savings"]
                    }
                }
            }
            
            // write back to database
            writeToBudgetBuckets(needs: currNeeds, wants: newWants, savings: currSavings)
        } catch {
            print("AddWants Error: \(error)")
        }
    }
    
    func addToSavings(income:Double) {
        do {
            var newSavings:Double = 0
            
            var currWants:Double = 0
            var currNeeds:Double = 0
            
            // read from database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let savings = rows["savings"] as? Double {
                        newSavings = savings + income
                        print("newSavings Amount: ", newSavings)
                        
                        currWants = rows["wants"]
                        currNeeds = rows["needs"]
                    }
                }
            }
            
            // write back to database
            writeToBudgetBuckets(needs: currNeeds, wants: currWants, savings: newSavings)
        } catch {
            print("AddSavings Error: \(error)")
        }
    }
    
    
    func subtractNeeds (expenses:Double) {
        do {
            var newNeeds:Double = 0
            
            var currWants:Double = 0
            var currSavings:Double = 0
            
            // read from database table "BudgetBuckets"
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let needs = rows["needs"] as? Double {
                        newNeeds = needs - expenses
                        print("NewNeeds Amount: ", newNeeds)
                        
                        currWants = rows["wants"]
                        currSavings = rows["savings"]
                    }
                }
            }
            writeToBudgetBuckets(needs: newNeeds, wants: currWants, savings: currSavings)
        } catch {
            print("AddNeeds Error: \(error)")
        }
    }
    
    func substractWants (expenses:Double) {
        do {
            var newWants:Double = 0
            
            var currNeeds:Double = 0
            var currSavings:Double = 0
            
            // read from database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let wants = rows["wants"] as? Double {
                        newWants = wants - expenses
                        print("NewWants Amount: ", newWants)
                        
                        currNeeds = rows["needs"]
                        currSavings = rows["savings"]
                    }
                }
            }
            
            // write back to database
            writeToBudgetBuckets(needs: currNeeds, wants: newWants, savings: currSavings)
        } catch {
            print("AddWants Error: \(error)")
        }
    }
    
    func subtractSavings (expenses:Double) {
        do {
            var newSavings:Double = 0
            
            var currWants:Double = 0
            var currNeeds:Double = 0
            
            // read from database
            try database.reader.read { db in
                if let rows = try Row.fetchOne(db, sql: "SELECT needs,wants,savings FROM BudgetBuckets") {
                    if let savings = rows["savings"] as? Double {
                        newSavings = savings - expenses
                        print("newSavings Amount: ", newSavings)
                        
                        currWants = rows["wants"]
                        currNeeds = rows["needs"]
                    }
                }
            }
            
            // write back to database
            writeToBudgetBuckets(needs: currNeeds, wants: currWants, savings: newSavings)
        } catch {
            print("AddSavings Error: \(error)")
        }
    }
    
    // RESET
    func resetBudgetBuckets() {
        writeToBudgetBuckets(needs: 0, wants: 0, savings: 0)
    }
}

