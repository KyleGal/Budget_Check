//
//  localDatabase.swift
//  Budget Check V2
//
//  Created by Kyle Gabriel Galvez on 8/31/23.
//

import Foundation
import GRDB

struct SQLiteDatabase {
    
    // write to database
    internal let writer:DatabaseWriter
    
    // migrator: manages and apply changes to database over time
    init(_ writer:DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }
    
    // read database
    var reader: DatabaseReader {
        writer
    }
}

// database connection
extension SQLiteDatabase {
    static let shared = makeShared()
    
    static func makeShared() -> SQLiteDatabase {
        do {
            let fileManager = FileManager()
            
            let folder = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("database", isDirectory: true)
            
            // opening an already created database will fail if "withIn.." is false
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            // create database file
            let databaseUrl = folder.appendingPathComponent("db.sqlite")
            // open database connection
            let writer = try DatabaseQueue(path: databaseUrl.path)
            // instantiate database with "writer" that we created below
            let database = try SQLiteDatabase(writer)
            
            return database
            
        } catch {
            fatalError("ERROR: \(error)")
        }
    }
}

// migrator and table
extension SQLiteDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // debug tool
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        // version control
        migrator.registerMigration("") { db in
            try createTable(db)
        }
        return migrator
    }
    
    // database schema
    private func createTable(_ db: GRDB.Database) throws {
        try db.create(table: "databaseTransactionModel") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("date", .text).notNull()
            t.column("categoryID", .integer).notNull()
            t.column("amount", .double).notNull()
            t.column("type", .text).notNull()
            t.column("isExpense", .boolean).notNull() //0 = no; 1 = yes
        }
        
        try db.create(table: "BudgetBuckets") { t in
            t.column("needs", .double).notNull()
            t.column("wants", .double).notNull()
            t.column("savings", .double).notNull()
        }
    }
}

