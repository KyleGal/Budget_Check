//
//  TransactionModel.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import Foundation
import SwiftUIFontIcon

// Transaction Object
    // Identifiable protocol allows us identify different 'Transaction' objects even if they have the same name ('id' will be different)
    // Decodable makes this struct well decodable
    // Hashable has similar idea to decodable
struct Transaction: Identifiable, Decodable, Hashable {
    //let values are only readable
    let id: Int
    let date: String
    let institution: String
    let account: String
    // var values are editable
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryId: Int
    var category: String
    let isPending: Bool
    var isTransfer: Bool
    var isExpense: Bool
    var isEdited: Bool
    
    // get icon according to categoryId else display a question icon
    var icon: FontAwesomeCode {
        if let category = Category.all.first(where: {$0.id == categoryId}) {
            return category.icon
        }
        return .question
    }
    
    // makes data look in the format of mm/dd/yyyy
    var dateParsed: Date {
        date.dateParsed()
    }
    
    // if transaction is income or expense
    var signedAmount: Double {
        return type == TransactionType.credit.rawValue ? amount : -amount
    }
    
    // date formatting for full list
    var month: String {
        dateParsed.formatted(.dateTime.year().month(.wide))
    }
    
    // budget category Groupings
    var budgetCategory: Budget {
        if let category = Category.all.first(where: {$0.id == categoryId}) {
            return category.budgetCategory
        }
        return Budget.other
    }
}

// enum defines your own data type with the case being the different values that can be accepted
enum TransactionType: String {
    case debit = "debit"
    case credit = "credit"
}


// Category object
struct Category {
    let id: Int
    let name: String
    let icon: FontAwesomeCode
    let budgetCategory: Budget
    // since below is optional we make it var along with adding '?' at end
    var mainCategoryId: Int?
}

// connects category name with an id and icon
extension Category {
// main categories
    static let income = Category(id: 1, name: "Income", icon: .dollar_sign, budgetCategory: .income)
    
    // Wants
    static let entertainment = Category(id: 2, name: "Entertainment", icon:.film, budgetCategory: .wants)
    static let foodAndDining = Category(id: 3, name:"Food & Dining", icon: .hamburger, budgetCategory: .wants)
    static let shopping = Category(id: 4, name: "Shopping", icon: .shopping_cart, budgetCategory: .wants)
    
    // Needs
    static let autoAndTransport = Category(id: 5, name:"Auto & Transport", icon: .car_alt, budgetCategory: .needs)
    static let billsAndUtilities = Category(id: 6, name: "Bills & Utilities", icon: .file_invoice_dollar, budgetCategory: .needs)
    static let groceries = Category(id: 7, name: "Groceries", icon: .shopping_basket, budgetCategory: .needs)
    
    // Others (FIXME: HOW WOULD I CATEGORIZE PAYING A CREDIT CARD OR TRANSFERS)
    static let transfer = Category(id: 8, name: "Transfer", icon: .exchange_alt, budgetCategory: .income)
    static let creditCardPayment = Category(id: 9, name: "Credit Card Payment", icon: .credit_card, budgetCategory: .other)
//    static let feesAndCharges = Category(id: 4, name: "Fees & Charges", icon: .hand_holding_usd)
//    static let home = Category(id: 6, name:"Home", icon:.home)
    

// TODO: Sub Categories will be created in further versions
    // sub categories
//    static let publicTransportation = Category(id: 101, name: "Public Transportathin", icon: .bus, mainCategoryId: 1)
//    static let taxi = Category(id: 102, name:"Taxi", icon: .taxi, mainCategoryId: 1)
//    static let mobilePhone = Category(id: 201, name:"Mobile Phone", icon: .mobile_alt, mainCategoryId: 2)
//    static let moviesAndDVDs = Category(id: 301, name:"Movies & DVDs", icon: .film, mainCategoryId: 3)
//    static let bankFee = Category(id: 401, name:"Bank Fee", icon: .hand_holding_usd, mainCategoryId: 4)
//    static let financeCharge = Category(id: 402, name:"Finance Charge", icon: .hand_holding_usd, mainCategoryId: 4)
//    static let groceries = Category(id: 501, name: "Groceries", icon: .shopping_basket, mainCategoryId: 5)
//    static let restaurants = Category(id: 502, name:"Restaurants", icon: .utensils, mainCategoryId: 5)
//    static let rent = Category(id: 601, name: "Rent",icon: .house_user, mainCategoryId: 6)
//    static let homeSupplies = Category(id: 602, name:"Home Supplies", icon:.lightbulb, mainCategoryId: 6)
//    static let paycheque = Category(id: 701, name:"Paycheque", icon:.dollar_sign, mainCategoryId: 7)
//    static let software = Category(id: 801, name:"Software", icon: .icons, mainCategoryId: 8)
//    static let creditCardPayment = Category(id: 901, name: "Credit Card Payment", icon:.exchange_alt, mainCategoryId: 9)
}

// create our categories and subcategories
extension Category {
    static let categories: [Category] = [
        .income,
        // Wants
        .shopping,
        .entertainment,
        .foodAndDining,
        
        // Needs
        .autoAndTransport,
        .billsAndUtilities,
        .groceries,
        
        // Other
        .transfer
//        .home,
//        .feesAndCharges,
    ]

// TODO: Better implement in further versions
//    static let subCategories: [Category] = [
//        .publicTransportation,
//        .taxi,
//        .mobilePhone,
//        .moviesAndDVDs,
//        .bankFee,
//        .financeCharge,
//        .groceries,
//        .restaurants,
//        .homeSupplies,
//        .paycheque,
//        .software,
//        .creditCardPayment
//    ]
    
    static let all: [Category] = categories // + subCategories
}

// Budget Object
struct Budget : Hashable, Decodable {
    let name: String
    var amount: Double = 0.00
}

extension Budget {
    static let income = Budget(name: "Income")
    static let wants = Budget(name: "Wants")
    static let needs = Budget(name: "Needs")
    static let savings = Budget(name: "Savings")
    // unknown transaction category
    static let other = Budget(name: "Other")
}

extension Budget {
    static let budget: [Budget] = [
        .income,
        .wants,
        .needs,
        .savings,
        .other
    ]
}
