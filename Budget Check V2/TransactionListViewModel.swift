//
//  TransactionListViewModel.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import Foundation
import Combine
import Collections
import GRDB

// typealias for a data type makes it reusable and easy to refer to
    // below is a dictionary of string w/ array of transaction
typealias TransactionGroup = OrderedDictionary<String, [Transaction]>

    // Array of String, Double Tuple: String = Date, Double = Amount
typealias TransactionPrefixSum = [(String, Double)]

typealias BudgetGroup = OrderedDictionary<Budget, [Transaction]>

// final class
// ObservableObject (Combine framework) turns any object into a publisher and notify subscribers of state changes
final class TransactionListViewModel: ObservableObject {
    // @Published sends notifs to subscribers whenever its value has changed
    @Published var transactions: [Transaction] = []
    
    // database initialization
    let database = SQLiteDatabase.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        // guard keywords allows for an error catch if the initial object is invalid
        guard let url = URL(string: "https://gist.githubusercontent.com/KyleGal/f0f41bd582a469cd3e08b940ea4bc7d0/raw/7537f8acadd4f93b00e9c5e4ac2ea7cdd99e26d4/Data.json") else {
            print("Invalid URL")
            return
        }
        
        // fetch data from an api (but here use a url from Combine)
        // handles incoming data
        URLSession.shared.dataTaskPublisher(for: url)
        // tryMap responses and allows us to throw an error if something goes wrong
            .tryMap { (data, response) -> Data in
                // checks if their is HTTP url response and status code == 200 else dump response and throw error
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }
                return data
            }
        // decode using JSONDecoder to transform incoming json into usable data by adding 'Decodable' keyword to Transaction struct
            .decode(type: [Transaction].self, decoder: JSONDecoder())
        // receive data on main thread to perform updates on main UI
            .receive(on: DispatchQueue.main)
        // sink allows us to process data
            .sink { completion in
                // handles successful or failure cases when fetching transactions
                switch completion {
                case .failure(let error):
                    print("Error fetching transactions: ", error.localizedDescription)
                case .finished:
                    print("Finished fetching transactions")
                    self.moveTransactionsToDatabase()
                }
                // handles data output
                // weak self creates a weak reference to self to prevent memory leaks as it will release the memory when necessary
            } receiveValue: { [weak self] result in
                // store results in transactions array
                self?.transactions = result
                // dump transactions for testing
                //                dump(self?.transactions)
            }
        // store
            .store(in: &cancellables)
    }
    
    // write transactions to database (temporary)
    func moveTransactionsToDatabase() {
        print("moving transactions to database")
        for transaction in transactions {
            let transactionDBModel = DatabaseTransactionModel(
                id: transaction.id,
                name: transaction.institution,
                date: transaction.date,
                categoryID: transaction.categoryId,
                amount: transaction.amount,
                type: transaction.type,
                isExpense: transaction.isExpense
            )
            
            // insert transactions into database
            addTransaction(name: transactionDBModel.name, date: transactionDBModel.date, categoryID: transactionDBModel.categoryID, amount: transactionDBModel.amount, type: transactionDBModel.type, isExpense: transactionDBModel.isExpense)
        }
        addToNeeds(income: 50)
        addToSavings(income: 100)
        addToWants(income: 15)
        print("Finished moving transactions")
    }
    
    
    func groupTransactionsByMonth() -> TransactionGroup {
        // checks if transaction array is empty else we return empty dictinary
        guard !transactions.isEmpty else {return[:] }
        // group transactions by common variable (month)
        let groupedTransactions = TransactionGroup(grouping: transactions) { $0.month}
        
        return groupedTransactions
    }
    
    // add up transactions to display in line chart
    func accumulateTransaction() -> TransactionPrefixSum {
        print("accumulateTransactions")
        // base case if transaction list is empty
        guard !transactions.isEmpty else {return []}
        
        let today = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let dateInterval = DateInterval(start: thirtyDaysAgo, end: today)
        print("dateInterval", dateInterval)
        
        // single value
        var sum: Double = .zero
        // set of values
        var cumulativeSum = TransactionPrefixSum()
        // total of all transactions
        var transactionSum : (String, Double)?
        
        // gathers transactions from last thirty days to get cumulativeSum
        for date in stride(from: thirtyDaysAgo, to: today, by: 60*60*24) {
            let dailyExpenses = transactions.filter { $0.dateParsed == date}

            var dailyTotal: Double = .zero
            for transaction in dailyExpenses {
                dailyTotal += transaction.signedAmount
            }
            
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            
            cumulativeSum.append((date.formatted(), sum))
            print(date.formatted(), "dailyTotal:", dailyTotal, "sum:", sum)
        }

        // TODO: edge case where there are no transactions for the month (should display last known sum in straight line)
        if sum == 0, let lastNonZeroTransaction = transactions.first(where: { $0.signedAmount != 0 }) {
            // hopefully get last known sum
            var allTransactionSum: Double = .zero
            for transaction in transactions {
                allTransactionSum += transaction.signedAmount
            }
            // correctly format
            transactionSum = (today.formatted(), allTransactionSum.roundedTo2Digits())
            
            cumulativeSum = []
            cumulativeSum.append((today.formatted(), 0.0))
            for _ in 1...29 {
                cumulativeSum.append(transactionSum!)
            }
            
            let dateString = lastNonZeroTransaction.dateParsed.formatted()
            print("Last non-zero transaction added:", dateString, "sum:", allTransactionSum.roundedTo2Digits())
        }
        
        return cumulativeSum
    }
    
    // Budget Category Groupings
    
//    func accumulateWantsTransactions() -> Double {
//        print("accumulateWantsTransactions")
//        guard !transactions.isEmpty else {return 0.00}
//
//        // Wants are 30% of income
//        var incomeSum: Double = accumulateIncome() * 0.30
//        print("Wants Allocation:", incomeSum.roundedTo2Digits())
//
//        for transaction in transactions {
//            if transaction.signedAmount <= 0 && transaction.budgetCategory == .wants{
//                incomeSum += transaction.signedAmount
//            }
//        }
//        print("Wants:", incomeSum.roundedTo2Digits())
//        return incomeSum.roundedTo2Digits()
//    }
    
    
//    func accumulateNeedsTransactions() -> Double {
//        print("accumulateNeedsTransactions")
//        guard !transactions.isEmpty else {return 0.00}
//
//        // Needs are 50% of income
//        var incomeSum: Double = accumulateIncome() * 0.50
//        print("Needs Allocation:", incomeSum.roundedTo2Digits())
//
//        for transaction in transactions {
//            if transaction.signedAmount <= 0 && transaction.budgetCategory == .needs {
//                incomeSum += transaction.signedAmount
//            }
//        }
//        print("Needs:", incomeSum.roundedTo2Digits())
//        return incomeSum.roundedTo2Digits()
//    }
    
    
//    func accumulateSavingsTransactions() -> Double {
//        print("accumulateSavingsTransactions")
//        guard !transactions.isEmpty else {return 0.00}
//
//        // Savings are 20% of income
//        var incomeSum: Double = accumulateIncome() * 0.20
//        print("Savings Allocation:", incomeSum.roundedTo2Digits())
//
//        for transaction in transactions {
//            if transaction.signedAmount <= 0 && transaction.budgetCategory == .savings {
//                incomeSum += transaction.signedAmount
//            }
//        }
//        print("Savings:", incomeSum.roundedTo2Digits())
//        return incomeSum.roundedTo2Digits()
//    }
}

struct DatabaseTransactionModel: Codable, FetchableRecord, PersistableRecord {
    var id: Int?
    var name: String
    var date: String
    var categoryID: Int
    var amount: Double
    var type: TransactionType.RawValue
    var isExpense: Bool
    
    init(id:Int?, name:String, date: String, categoryID: Int, amount: Double, type: TransactionType.RawValue, isExpense: Bool) {
        self.id = id
        self.name = name
        self.date = date
        self.categoryID = categoryID
        self.amount = amount
        self.type = type
        self.isExpense = isExpense
    }
}

struct BudgetBucketModel: Codable, FetchableRecord, PersistableRecord {
    var needs: Double
    var wants: Double
    var savings: Double
}
