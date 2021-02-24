//
//  Persistence.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    private(set) var remoteChange = false
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        DataModel.setupPreviewData(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Wots4T")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.viewContext.automaticallyMergesChangesFromParent = true
            let description = container.persistentStoreDescriptions.first
            description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            description?.setOption(true as NSNumber, forKey: remoteChangeKey)
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        if !inMemory {
            let viewContext = container.viewContext
            
            let request = NSFetchRequest<CategoryMO>(entityName: CategoryMO.tableName)
            let read = try? viewContext.fetch(request)
            
            if read == nil || read!.isEmpty {
                // DataModel.setupPreviewData(context: viewContext)
            }
            
            do {
                try viewContext.save()
            } catch {
                fatalError()
            }
        }
    }
}
