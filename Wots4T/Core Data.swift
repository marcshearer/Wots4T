//
//  Core Data.swift
//  Wots4T
//
//  Created by Marc Shearer on 21/01/2021.
//

import CoreData
 
public enum SortDirection {
    case ascending
    case descending
}

class CoreData {
    
    // Core data context - set up in initialise
    static var context: NSManagedObjectContext!

    class func fetch<MO: NSManagedObject>(from entityName: String,
                                          filter: NSPredicate! = nil, filter2: NSPredicate! = nil, limit: Int = 0,
                                          sort: [(key: String, direction: SortDirection)]) -> [MO] {
        var filterArray: [NSPredicate]? = nil
        if filter != nil {
            filterArray = [filter]
        }
        if filter2 != nil {
            filterArray?.append(filter2)
        }
        return CoreData.fetch(from: entityName, filter: filterArray, limit:limit, sort: sort)
    }
    
    class func fetch<MO: NSManagedObject>(from entityName: String, filter: NSPredicate! = nil, filter2: NSPredicate! = nil, limit: Int = 0,
                                          sort: (key: String, direction: SortDirection)...) -> [MO] {
        return CoreData.fetch(from: entityName, filter: filter, filter2: filter2, limit:limit, sort: sort)
    }
    
    class func fetch<MO: NSManagedObject>(from entityName: String, filter: [NSPredicate]! = nil, limit: Int = 0,
                     sort: [(key: String, direction: SortDirection)]) -> [MO] {
        // Fetch an array of managed objects from core data
        var results: [MO] = []
        var read:[MO] = []
        let readSize = 100
        var finished = false
        var requestOffset: Int!
        
        if let context = CoreData.context {
            // Create fetch request
            
            let request = NSFetchRequest<MO>(entityName: entityName)
            
            // Add any predicates
            if filter != nil {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filter!)
            }
            
            // Add any sort values
            if sort.count > 0 {
                var sortDescriptors: [NSSortDescriptor] = []
                for sortElement in sort {
                    sortDescriptors.append(NSSortDescriptor(key: sortElement.key, ascending: sortElement.direction == .ascending))
                }
                request.sortDescriptors = sortDescriptors
            }
            
            // Add any limit
            if limit != 0 {
                request.fetchLimit = limit
            } else {
                request.fetchBatchSize = readSize
            }
            
            while !finished {
                
                if let requestOffset = requestOffset {
                    request.fetchOffset = requestOffset
                }
                
                read = []
                
                // Execute the query
                do {
                    read = try context.fetch(request)
                } catch {
                    fatalError("Unexpected error")
                }
                
                results += read
                if limit != 0 || read.count < readSize {
                    finished = true
                } else {
                    requestOffset = results.count
                }
            }
        } else {
            fatalError("Unexpected error")
        }
        return results
    }
    
    @discardableResult class func update(errorHandler: (() -> ())! = nil, updateLogic: () -> (), calledFrom: String = #function) -> Bool {
        
        if let context = CoreData.context {

            updateLogic()
            
            context.performAndWait {
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        if errorHandler != nil {
                            errorHandler()
                        } else {
                            fatalError("Unresolved error \(nserror) when called from \(calledFrom), \(nserror.userInfo)")
                        }
                    }
                }
            }
        } else {
            if errorHandler != nil {
                errorHandler()
            } else {
                fatalError("Unexpected error")
            }
        }
        
        return true
    }
    
    class func create<MO: NSManagedObject>(from entityName: String) -> MO {
        var result: MO!
        if let context = CoreData.context {
            if let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) {
                result =  MO(entity: entityDescription, insertInto: context) as MO
            }
        }
        return result
    }
    
    class func delete<MO: NSManagedObject>(record: MO) {
        if let context = CoreData.context {
            context.delete(record)
        }
    }
}
