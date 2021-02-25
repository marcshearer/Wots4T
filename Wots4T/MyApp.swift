//
//  MyApp.swift
//  Wots4T
//
//  Created by Marc Shearer on 25/02/2021.
//

import CloudKit
import UIKit
import CoreData

enum UserDefault: String, CaseIterable {
    case database = "database"

    public var name: String { self.rawValue }
    
    public var defaultValue: Any {
        switch self {
        case .database:
            return "unknown"
        }
    }
}

class MyApp {
    
    static let shared = MyApp()
    
    public static var database: String = "unknown"
    public static let cloudContainer = CKContainer.init(identifier: Config.iCloudIdentifier)
    public static let publicDatabase = cloudContainer.publicCloudDatabase
    public static let privateDatabase = cloudContainer.privateCloudDatabase

    public func start() {
        DataModel.shared.load()
        Themes.selectTheme(.standard)
        self.registerDefaults()
        // Remove (CAREFULLY) if you want to clear the iCloud DB DatabaseUtilities.initialiseAll() {
            self.setupDatabase()
        //}
    
        UITextView.appearance().backgroundColor = .clear
    }
    
    private func setupDatabase() {
        
        // Get saved database
        MyApp.database = UserDefaults.standard.string(forKey: UserDefault.database.name) ?? "unknown"
        
        // Check which database we are connected to
        ICloud.shared.getDatabaseIdentifier { (success, errorMessage, database) in
            
            if success {
                Utility.mainThread {
                    
                    // Store database identifier
                    MyApp.database = database ?? "unknown"
                    UserDefaults.standard.set(database, forKey: UserDefault.database.name)
                }
            }
        }
        
        // Check if this iCloud account has central data - if not then use default set
        var categories = 0
        ICloud.shared.download(recordType: "CD_\(CategoryMO.tableName)", database: MyApp.privateDatabase,
           downloadAction:
                { (_) in
                    categories += 1
                },
           completeAction: {
                    if categories == 0 {
                        self.setupPreviewData()
                    }
                },
           failureAction: { (error) in
                    if categories == 0 {
                        self.setupPreviewData()
                    }
                })
    }
     
    private func setupPreviewData() {
        let viewContext = CoreData.context!
        
        let request = NSFetchRequest<CategoryMO>(entityName: CategoryMO.tableName)
        let read = try? viewContext.fetch(request)
        
        if read == nil || read!.isEmpty {
            // No local data - get it from the cloud
            DataModel.setupPreviewData(context: viewContext)
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
