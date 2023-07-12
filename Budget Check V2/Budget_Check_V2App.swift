//
//  Budget_Check_V2App.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import SwiftUI

@main
struct Budget_Check_V2App: App {
    // @StateObject allows us to use the object within other views
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // allows all children of this view to use the @StateObject variable
                .environmentObject(transactionListVM)
        }
    }
}
