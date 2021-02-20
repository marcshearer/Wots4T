//
//  Preview Data.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/02/2021.
//

import CoreData

extension DataModel {
    
    public static func setupPreviewData(context: NSManagedObjectContext) {
                
        let carbs = CategoryMO(context: context, name: "Carbs", importance: .highest)
        let protein = CategoryMO(context: context, name: "Protein", importance: .high)
        let cuisine = CategoryMO(context: context, name: "Cuisine", importance: .medium)
        
        let pasta = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Pasta", frequency: .veryOften)
        let rice = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Rice", frequency: .veryOften)
        let potato = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Potato", frequency: .veryOften)
        let bread = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Bread", frequency: .occasionally)
        let couscous = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Couscous", frequency: .occasionally)
        let lentils = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Lentils", frequency: .rarely)

        let chicken = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Chicken", frequency: .veryOften)
        let veggie = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Veggie", frequency: .often)
        let beef = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Beef", frequency: .often)
        let fish = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Fish", frequency: .occasionally)
        let pork = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Pork", frequency: .occasionally)
        let lamb = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Lamb", frequency: .rarely)
        let sausage = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Sausage", frequency: .rarely)
        let various = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Various", frequency: .rarely)
        let duck = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Duck", frequency: .rarely)

        let med = CategoryValueMO(context: context, categoryId: cuisine.categoryId, name: "Med", frequency: .veryOften)
        let trad = CategoryValueMO(context: context, categoryId: cuisine.categoryId, name: "Trad", frequency: .often)
        let oriental = CategoryValueMO(context: context, categoryId: cuisine.categoryId, name: "Oriental", frequency: .often)
        let indian = CategoryValueMO(context: context, categoryId: cuisine.categoryId, name: "Indian", frequency: .often)
        let mexican = CategoryValueMO(context: context, categoryId: cuisine.categoryId, name: "Mexican", frequency: .often)
     
        func meal(name: String, desc: String? = nil, carbs carbsValue: CategoryValueMO, protein proteinValue: CategoryValueMO, cuisine cuisineValue: CategoryValueMO, url: String = "", notes: String = "") {
            let mealMO = MealMO(context: context, name: name, desc: desc ?? name, url: url, notes: notes)
            let _ = MealCategoryValueMO(context: context, mealId: mealMO.mealId, categoryId: carbs.categoryId, valueId: carbsValue.valueId)
            let _ = MealCategoryValueMO(context: context, mealId: mealMO.mealId, categoryId: protein.categoryId, valueId: proteinValue.valueId)
            let _ = MealCategoryValueMO(context: context, mealId: mealMO.mealId, categoryId: cuisine.categoryId, valueId: cuisineValue.valueId)
        }
        
        meal(name: "Chickpea Kofta", desc: "potato veggie indian", carbs: potato, protein: veggie, cuisine: indian, notes: "Source: Home Fresh")
        meal(name: "Sausage and Mash", desc: "potato sausage trad", carbs: potato, protein: sausage, cuisine: trad)
        meal(name: "Chicken Stew", desc: "potato chicken trad", carbs: potato, protein: chicken, cuisine: trad, notes: "Source: Home Fresh")
        meal(name: "Chorizo Crusted Cod", desc: "potato fish med", carbs: potato, protein: fish, cuisine: med)
        meal(name: "Cottage Pie", desc: "potato beef trad", carbs: potato, protein: beef, cuisine: trad)
        meal(name: "Fish and Chips", desc: "potato fish trad", carbs: potato, protein: fish, cuisine: trad)
        meal(name: "Chicken pie", desc: "potato chicken trad", carbs: potato, protein: chicken, cuisine: trad)
        meal(name: "Thai Salmon Fishcakes", desc: "potato fish oriental", carbs: potato, protein: fish, cuisine: oriental, notes: "Source: Home Fresh")
        meal(name: "Fish pie", desc: "potato fish trad", carbs: potato, protein: fish, cuisine: trad, notes: "Source: Home Fresh")
        meal(name: "Spaghetti Carbonara", desc: "pasta pork med", carbs: pasta, protein: pork, cuisine: med)
        meal(name: "Chorizo Sweetcorn Pasta", desc: "pasta pork med", carbs: pasta, protein: pork, cuisine: med)
        meal(name: "Lemony Chicken Linguine", desc: "pasta chicken med", carbs: pasta, protein: chicken, cuisine: med)
        meal(name: "Spag Bog", desc: "pasta beef med", carbs: pasta, protein: beef, cuisine: med)
        meal(name: "Lasagne", desc: "pasta beef med", carbs: pasta, protein: beef, cuisine: med)
        meal(name: "Moussaka", desc: "potato lamb med", carbs: potato, protein: lamb, cuisine: med)
        meal(name: "Chicken Pasta Bake", desc: "pasta chicken med", carbs: pasta, protein: chicken, cuisine: med)
        meal(name: "Tortelloni", desc: "pasta veggie med", carbs: pasta, protein: veggie, cuisine: med)
        meal(name: "Generic Stir-fry", desc: "pasta various oriental", carbs: pasta, protein: various, cuisine: oriental)
        meal(name: "Creamy Chicken and Rice", desc: "rice chicken trad", carbs: rice, protein: chicken, cuisine: trad)
        meal(name: "Thai Sticky Pork", desc: "rice pork oriental", carbs: rice, protein: pork, cuisine: oriental)
        meal(name: "Chicken Korma", desc: "rice chicken indian", carbs: rice, protein: chicken, cuisine: indian, notes: "Source: Jamie Oliver")
        meal(name: "Beef Rogan Josh", desc: "rice beef indian", carbs: rice, protein: beef, cuisine: indian)
        meal(name: "Hoisin Chicken", desc: "rice chicken oriental", carbs: rice, protein: chicken, cuisine: oriental, notes: "Source: Home Fresh")
        meal(name: "Lamb Tagine", desc: "pasta lamb med", carbs: couscous, protein: lamb, cuisine: med)
        meal(name: "Sweet Potato Curry", desc: "rice veggie indian", carbs: rice, protein: veggie, cuisine: indian)
        meal(name: "Sweet and Sour Pork", desc: "rice pork oriental", carbs: rice, protein: pork, cuisine: oriental)
        meal(name: "Vegetable Curry", desc: "rice veggie indian", carbs: rice, protein: veggie, cuisine: indian)
        meal(name: "Chicken and Lentils", desc: "lentils chicken trad", carbs: lentils, protein: chicken, cuisine: trad, notes: "Source: Home Fresh")
        meal(name: "Chilli con Carne", desc: "rice beef mexican", carbs: rice, protein: beef, cuisine: mexican)
        meal(name: "Fajitas", desc: "bread chicken mexican", carbs: bread, protein: chicken, cuisine: mexican)
        meal(name: "Pizza", desc: "bread various med", carbs: bread, protein: various, cuisine: med)
        meal(name: "Enchilladas", desc: "bread beef mexican", carbs: bread, protein: beef, cuisine: mexican)
        meal(name: "Crispy Duck", desc: "bread duck oriental", carbs: bread, protein: duck, cuisine: oriental)
        meal(name: "Mango Chicken Wraps", desc: "bread chicken oriental", carbs: bread, protein: chicken, cuisine: oriental, notes: "Source: Home Fresh")
        meal(name: "Pork and Ramen", desc: "pasta pork oriental", carbs: pasta, protein: pork, cuisine: oriental)
        meal(name: "Teryaki Salmon", desc: "rice fish oriental", carbs: rice, protein: fish, cuisine: oriental)
    }
}
