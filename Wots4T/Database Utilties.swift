//
//  Database Utilties.swift
//  Wots4T
//
//  Created by Marc Shearer on 25/02/2021.
//

import Foundation
import CloudKit

class DatabaseUtilities {
    
    static func initialiseAll(completion: (()->())? = nil) {
        // INITIALISES PRIVATE CLOUD DATABASE !!!!!!!!!!!!!!!
        self.initialise(tables: [
            CategoryMO.tableName,
            CategoryValueMO.tableName,
            MealMO.tableName,
            MealCategoryValueMO.tableName,
            MealAttachmentMO.tableName,
            AllocationMO.tableName
        ], completion: completion)
    }
    
    private static func initialise(tables: [String], completion: (()->())? = nil, index: Int = 0) {
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
                    DatabaseUtilities.initialise(tables: tables, completion: completion, index: index + 1)
                }
            })
        }
    }
}
