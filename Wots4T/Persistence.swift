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

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let spagbogUUID = UUID()
        let lasagneUUID = UUID()
        let vegCurryUUID = UUID()
        let chickenStirFryUUID = UUID()
        let today = DayNumber.today
        
        let meals: [MealMO] = [
            MealMO(context: viewContext, mealId: spagbogUUID, name: "Spaghetti Bolognaise", desc: "Spaghetti with a beef mince sauce", url: "https://www.bbc.co.uk/food/recipes/spaghettibolognese_67868"),
            MealMO(context: viewContext, mealId: lasagneUUID, name: "Lasagne", desc: "Layers of pasta and mince with cheese", url: "https://www.bbc.co.uk/food/recipes/express_lasagne_51375"),
            MealMO(context: viewContext, mealId: vegCurryUUID, name: "Vegetable Curry", desc: "Mixed vegetables in a spicy sauce", url: "https://www.bbc.co.uk/food/recipes/mushroom_chickpea_and_71193"),
            MealMO(context: viewContext, mealId: chickenStirFryUUID, name: "Chicken Stir Fry", desc: "Chicken with stir fried vegetables", url: "https://www.bbc.co.uk/food/recipes/vegetablechickenstir_76805")
        ]

        let allocations: [AllocationMO] = [
            AllocationMO(context: viewContext, dayNumber: DayNumber.today - 1, slot: 0, mealId: chickenStirFryUUID),
            AllocationMO(context: viewContext, dayNumber: DayNumber.today + 1, slot: 0, mealId: vegCurryUUID)
        ]
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
            
            /*
            let viewContext = container.viewContext
             
            let spagbogUUID = UUID()
            let lasagneUUID = UUID()
            let vegCurryUUID = UUID()
            let chickenStirFryUUID = UUID()
            let today = DayNumber(from: Date())
            
            let _ = [
             MealMO(context: viewContext, mealId: spagbogUUID, name: "Spaghetti Bolognaise", desc: "Spaghetti with a beef mince sauce", url: "https://www.bbc.co.uk/food/recipes/spaghettibolognese_67868"),
             MealMO(context: viewContext, mealId: lasagneUUID, name: "Lasagne", desc: "Layers of pasta and mince with cheese", url: "https://www.bbc.co.uk/food/recipes/express_lasagne_51375"),
             MealMO(context: viewContext, mealId: vegCurryUUID, name: "Vegetable Curry", desc: "Mixed vegetables in a spicy sauce", url: "https://www.bbc.co.uk/food/recipes/mushroom_chickpea_and_71193"),
             MealMO(context: viewContext, mealId: chickenStirFryUUID, name: "Chicken Stir Fry", desc: "Chicken with stir fried vegetables", url: "https://www.bbc.co.uk/food/recipes/vegetablechickenstir_76805")
            ]
            let _ = [
                AllocationMO(context: viewContext, dayNumber: today, slot: 0, mealId: chickenStirFryUUID),
                AllocationMO(context: viewContext, dayNumber: today + 2, slot: 0, mealId: vegCurryUUID)
            ]
            do {
                try viewContext.save()
            } catch {
            }
            */
        }
    }
}

