//
//  Data.swift
//  Wots4T
//
//  Created by Marc Shearer on 21/01/2021.
//

import Foundation

class DataModel: ObservableObject {
    
    public static let shared = DataModel()
    
    @Published private(set) var meals: [MealViewModel] = []
    @Published private(set) var allocations: [AllocationViewModel] = []
    
    public func load() {
        
        /// **Builds in-memory mirror of meals and their ingredients with pointers to managed objects**
        //  Note that this infers that there will only ever be 1 instance of the app accessing the database
        
        let mealMOList = CoreData.fetch(from: MealMO.tableName, sort: (key: #keyPath(MealMO.lastDate), direction: .ascending)) as! [MealMO]
        let ingredientMOList = CoreData.fetch(from: MealIngredientMO.tableName) as! [MealIngredientMO]

        self.meals = []
        for mealMO in mealMOList {
            let ingredients = ingredientMOList.filter( { $0.mealId == mealMO.mealId } )
            self.meals.append(MealViewModel(mealMO: mealMO, ingredientMO: Set<MealIngredientMO>(ingredients)))
        }
        
        let allocationMOList = CoreData.fetch(from: AllocationMO.entity().name!, sort: (key: #keyPath(AllocationMO.dayNumber64), direction: .ascending), (key: #keyPath(AllocationMO.slot16), direction: .ascending)) as! [AllocationMO]

        self.allocations = []
        for allocationMO in allocationMOList {
            self.allocations.append(AllocationViewModel(allocationMO: allocationMO))
        }
    }
    
    /// Methods for meals and ingredients
    
    public func insert(meal: MealViewModel) {
        assert(meal.mealMO == nil && meal.mealIngredientMO.isEmpty, "Cannot insert a \(mealName) which already has managed objects")
        CoreData.update(updateLogic: {
            meal.mealMO = MealMO(context: CoreData.context, mealId: meal.mealId, name: meal.name, desc: meal.desc, lastDate: meal.lastDate)
            self.updateMO(meal: meal)
            self.meals.insert(meal, at: 0)
        })
    }
    
    public func remove(meal: MealViewModel) {
        assert(meal.mealMO != nil, "Cannot remove a \(mealName) which doesn't already have managed objects")
        if let index = self.meals.firstIndex(where: { $0.mealId == meal.mealId }) {
            CoreData.update(updateLogic: {
                if !meal.mealIngredientMO.isEmpty {
                    // Delete ingredients
                    self.updateIngredientsMO(meal: meal, ingredients: [])
                }
                CoreData.context.delete(meal.mealMO!)
                self.meals.remove(at: index)
            })
        }
    }
    
    public func save(meal: MealViewModel) {
        assert(meal.mealMO != nil, "Cannot save a \(mealName) which doesn't already have managed objects")
        CoreData.update(updateLogic: {
            self.updateMO(meal: meal)
        })
    }
    
    private func updateMO(meal: MealViewModel) {
            meal.mealMO!.mealId = meal.mealId
    }
    
    private func updateIngredientsMO(meal: MealViewModel, ingredients: Set<UUID>? = nil) {
        let ingredients = ingredients ?? meal.ingredients ?? []
        // First remove any MOs not in MO but not in ingredients
        for ingredient in meal.mealIngredientMO {
            if !ingredients.contains(ingredient.ingredientId) {
                meal.mealIngredientMO.remove(ingredient)
                CoreData.delete(record: ingredient)

            }
        }
        // Now add any MOs in ingredients but not in MO
        if !ingredients.isEmpty {
            let existingIngredients = meal.mealIngredientMO.map{$0.ingredientId}
            for ingredientId in ingredients {
                if !existingIngredients.contains(ingredientId) {
                    meal.mealIngredientMO.insert(MealIngredientMO(context: CoreData.context, mealId: meal.mealId, ingredientID: ingredientId))
                }
            }
        }
    }
    
    /// Methods for allocations
    
    public func insert(allocation: AllocationViewModel) {
        assert(allocation.allocationMO == nil, "Cannot insert a \(allocationName) which already has a managed object")
        CoreData.update(updateLogic: {
            allocation.allocationMO = AllocationMO(context: CoreData.context, dayNumber: allocation.dayNumber, slot: allocation.slot, mealId: allocation.meal.mealId)
            self.updateMO(allocation: allocation)
            self.allocations.insert(allocation, at: 0)
        })
    }
    
    public func remove(allocation: AllocationViewModel) {
        assert(allocation.allocationMO != nil, "Cannot remove a \(allocationName) which doesn't already have a managed object")
        if let index = self.allocations.firstIndex(where: { $0.dayNumber == allocation.dayNumber && $0.slot == allocation.slot }) {
            CoreData.update(updateLogic: {
                CoreData.context.delete(allocation.allocationMO!)
                self.allocations.remove(at: index)
            })
        }
    }
    
    public func save(allocation: AllocationViewModel) {
        assert(allocation.allocationMO != nil, "Cannot save a \(allocationName) which doesn't already have managed objects")
        CoreData.update(updateLogic: {
            self.updateMO(allocation: allocation)
        })
    }
    
    private func updateMO(allocation: AllocationViewModel) {
        allocation.allocationMO!.dayNumber = allocation.dayNumber
        allocation.allocationMO!.slot = allocation.slot
        allocation.allocationMO!.mealId = allocation.meal.mealId
    }
}
