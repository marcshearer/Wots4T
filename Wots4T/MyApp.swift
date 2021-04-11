//
//  MyApp.swift
//  Wots4T
//
//  Created by Marc Shearer on 25/02/2021.
//

import CloudKit
import CoreData
import SwiftUI

enum UserDefault: String, CaseIterable {
    case database
    case lastVersion
    case lastBuild
    case minVersion
    case minMessage
    case infoMessage

    public var name: String { "\(self)" }
    
    public var defaultValue: Any {
        switch self {
        case .database:
            return "unknown"
        case .lastVersion:
            return "0.0"
        case .lastBuild:
            return 0
        case .minVersion:
            return 0
        case .minMessage:
            return ""
        case .infoMessage:
            return ""
        }
    }
    
    public func set(_ value: Any) {
        UserDefaults.standard.set(value, forKey: self.name)
    }
    
    public var string: String {
        return UserDefaults.standard.string(forKey: self.name)!
    }
    
    public var int: Int {
        return UserDefaults.standard.integer(forKey: self.name)
    }
    
    public var bool: Bool {
        return UserDefaults.standard.bool(forKey: self.name)
    }
}

class MyApp {
    
    enum Target {
        case iOS
        case macOS
    }
    
    enum Database: String {
        case development = "Development"
        case production = "Production"
        case unknown = "Unknown"
        
        public var name: String {
            return self.rawValue
        }
    }
    
    static let shared = MyApp()
    
    /// Database to use - This  **MUST MUST MUST** match icloud entitlement
    static let expectedDatabase: Database = .production
    
    public static var database: Database = .unknown
    
    #if targetEnvironment(macCatalyst)
    public static let target: Target = .macOS
    #else
    public static let target: Target = .iOS
    #endif
    
    public static let cloudContainer = CKContainer.init(identifier: Config.iCloudIdentifier)
    public static let publicDatabase = cloudContainer.publicCloudDatabase
    public static let privateDatabase = cloudContainer.privateCloudDatabase

    public func start() {
        MasterData.shared.load()
        Themes.selectTheme(.standard)
        self.registerDefaults()
        Version.current.load()
        // Remove (CAREFULLY) if you want to clear the iCloud DB
        //DatabaseUtilities.initialiseAllCloud() {
            // Remove (CAREFULLY) if you want to clear the Core Data DB
            //DatabaseUtilities.initialiseAllCoreData()
            self.setupDatabase()
            // self.setupPreviewData()
        //}
        
        
        #if canImport(UIKit)
        UITextView.appearance().backgroundColor = .clear
        #endif
    }
    
    private func setupDatabase() {
        
        // Get saved database
        MyApp.database = Database(rawValue: UserDefault.database.string) ?? .unknown
        
        // Check which database we are connected to
        ICloud.shared.getDatabaseIdentifier { (success, errorMessage, database, minVersion, minMessage, infoMessage) in
            
            if success {
                Utility.mainThread {
                    
                    // Store database identifier
                    let cloudDatabase: Database = Database(rawValue: database ?? "") ?? .unknown
                    
                    if MyApp.database != .unknown && MyApp.database != cloudDatabase {
                        MessageBox.shared.show("This device was connected to the \(MyApp.database) database and is now trying to connect to the \(cloudDatabase) database") {
                            exit(1)
                        }
                    }
                    
                    MyApp.database = cloudDatabase
                    UserDefault.database.set(cloudDatabase.name)
                    Version.current.set(minVersion: minVersion ?? "", minMessage: minMessage ?? "", infoMessage: infoMessage ?? "")
                }
            }
        }
    }
     
    private func setupPreviewData() {
        // Be careful with enabling (removing //s above) this as it ends up doubling up data!
        let viewContext = CoreData.context!
        
        let request = NSFetchRequest<CategoryMO>(entityName: CategoryMO.tableName)
        let read = try? viewContext.fetch(request)
        
        if read == nil || read!.isEmpty {
            // No local data - get it from the cloud
            MasterData.setupPreviewData(context: viewContext)
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError()
        }
    }
    
    private func registerDefaults() {
        var initial: [String:Any] = [:]
        for value in UserDefault.allCases {
            initial[value.name] = value.defaultValue
        }
        UserDefaults.standard.register(defaults: initial)
    }
}

enum Wots4TError: Error {
    case invalidData
}
