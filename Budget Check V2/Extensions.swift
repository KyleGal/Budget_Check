//
//  Extensions.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 7/7/23.
//

import Foundation
import SwiftUI

// extensions allow you to add methods to existing types
extension Color {
    static let background = Color("Background")
    static let icon = Color("Icon")
    static let text = Color("Text")
    static let systemBackground = Color(uiColor: .systemBackground)
}

// we added allNumericUSA formatter to DateFormatter type
extension DateFormatter {
    static let allNumericUSA: DateFormatter = {
        print("Initializing DateFormatter")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter
    }()
}

// create a string function that formats the date
extension String {
    func dateParsed() -> Date {
        guard let parsedDate = DateFormatter.allNumericUSA.date(from: self) else {return Date()}
        
        return parsedDate
    }
}

// might need ": Strideable"
extension Date {
    func formatted() -> String {
        return self.formatted(.dateTime.year().month().day())
    }
}

extension Double {
    func roundedTo2Digits() -> Double {
        return (self * 100).rounded() / 100
    }
}
