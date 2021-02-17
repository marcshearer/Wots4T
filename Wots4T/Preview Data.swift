//
//  Preview Data.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/02/2021.
//

import CoreData

extension DataModel {
    
    public static func setupPreviewData(context: NSManagedObjectContext) {
        
        let carbsUUID = UUID()
        let proteinUUID = UUID()
        let cuisineUUID = UUID()
        
        let _: [CategoryMO] = [
            CategoryMO(context: context, categoryId: carbsUUID, name: "Carbs", importance: .highest),
            CategoryMO(context: context, categoryId: proteinUUID, name: "Protein", importance: .high),
            CategoryMO(context: context, categoryId: cuisineUUID, name: "Cuisine", importance: .medium)
        ]
        
        let pastaUUID = UUID()
        
        let _: [CategoryValueMO] = [
            CategoryValueMO(context: context, categoryId: carbsUUID, valueId: pastaUUID, name: "Pasta", frequency: .veryOften),
            CategoryValueMO(context: context, categoryId: carbsUUID, name: "Rice", frequency: .often),
            CategoryValueMO(context: context, categoryId: carbsUUID, name: "Potatoes", frequency: .often),
            CategoryValueMO(context: context, categoryId: carbsUUID, name: "Couscous", frequency: .occasionally),
            
            CategoryValueMO(context: context, categoryId: proteinUUID, name: "Chicken", frequency: .veryOften),
            CategoryValueMO(context: context, categoryId: proteinUUID, name: "Beef", frequency: .often),
            CategoryValueMO(context: context, categoryId: proteinUUID, name: "Fish", frequency: .often),
            CategoryValueMO(context: context, categoryId: proteinUUID, name: "Pork", frequency: .occasionally),
            
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "Italian", frequency: .veryOften),
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "British", frequency: .often),
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "Oriental", frequency: .often),
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "Indian", frequency: .often),
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "Mexican", frequency: .often),
            CategoryValueMO(context: context, categoryId: cuisineUUID, name: "French", frequency: .occasionally)
        ]
        
        let spagbogUUID = UUID()
        let lasagneUUID = UUID()
        let vegCurryUUID = UUID()
        let chickenStirFryUUID = UUID()

        let _: [MealMO] = [
            MealMO(context: context, mealId: spagbogUUID, name: "Spaghetti Bolognaise", desc: "Spaghetti with a beef mince sauce", url: "https://www.bbc.co.uk/food/recipes/spaghettibolognese_67868"),
            MealMO(context: context, mealId: lasagneUUID, name: "Lasagne", desc: "Layers of pasta and mince with cheese", url: "https://www.bbc.co.uk/food/recipes/express_lasagne_51375"),
            MealMO(context: context, mealId: vegCurryUUID, name: "Vegetable Curry", desc: "Mixed vegetables in a spicy sauce", url: "https://www.bbc.co.uk/food/recipes/mushroom_chickpea_and_71193"),
            MealMO(context: context, mealId: chickenStirFryUUID, name: "Chicken Stir Fry", desc: "Chicken with stir fried vegetables", url: "https://www.bbc.co.uk/food/recipes/vegetablechickenstir_76805")
        ]
        
        let _: [MealCategoryValueMO] = [
            MealCategoryValueMO(context: context, mealId: spagbogUUID, categoryId: carbsUUID, valueId: pastaUUID)
        ]

        let today = DayNumber.today

        let _: [AllocationMO] = [
            AllocationMO(context: context, dayNumber: today - 1, slot: 0, mealId: chickenStirFryUUID),
            AllocationMO(context: context, dayNumber: today + 1, slot: 0, mealId: vegCurryUUID)
        ]
    }
}
