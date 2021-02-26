//
//  Database Utilties.swift
//  Wots4T
//
//  Created by Marc Shearer on 25/02/2021.
//

import Foundation
import CloudKit

class DatabaseUtilities {
    
    static func initialiseAllCloud(completion: (()->())? = nil) {
        // INITIALISES PRIVATE CLOUD DATABASE !!!!!!!!!!!!!!!
        self.initialiseCloud(tables: [
            CategoryMO.tableName,
            CategoryValueMO.tableName,
            MealMO.tableName,
            MealCategoryValueMO.tableName,
            MealAttachmentMO.tableName,
            AllocationMO.tableName
        ], completion: completion)
    }
    
    private static func initialiseCloud(tables: [String], completion: (()->())? = nil, index: Int = 0) {
        if index >= tables.count {
            // Finished
            completion?()
        } else {
            // Next table
            ICloud.shared.initialise(recordType: "CD_\(tables[index])", database: MyApp.privateDatabase, completion: { (error) in
                if error != nil {
                    let ckError = error as? CKError
                    fatalError(ckError?.localizedDescription ?? error?.localizedDescription ?? "Unknown error")
                } else {
                    DatabaseUtilities.initialiseCloud(tables: tables, completion: completion, index: index + 1)
                }
            })
        }
    }
    
    static func initialiseAllCoreData(completion: (()->())? = nil) {
        // INITIALISES CORE DATA DATABASE !!!!!!!!!!!!!!!
        self.initialiseCloud(tables: [
            CategoryMO.tableName,
            CategoryValueMO.tableName,
            MealMO.tableName,
            MealCategoryValueMO.tableName,
            MealAttachmentMO.tableName,
            AllocationMO.tableName
        ], completion: completion)
    }
    
    private static func initialiseCoreData(tables: [String], completion: (()->())? = nil, index: Int = 0) {
        if index >= tables.count {
            // Finished
            completion?()
        } else {
            // Next table
            let records = CoreData.fetch(from: tables[index])
            for record in records {
                CoreData.delete(record: record)
            }
            DatabaseUtilities.initialiseCoreData(tables: tables, completion: completion, index: index + 1)
        }
    }
}
