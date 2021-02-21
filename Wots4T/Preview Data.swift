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
        let squash = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Squash", frequency: .occasionally)
        let lentils = CategoryValueMO(context: context, categoryId: carbs.categoryId, name: "Lentils", frequency: .rarely)

        let chicken = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Chicken", frequency: .veryOften)
        let veggie = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Veggie", frequency: .often)
        let beef = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Beef", frequency: .often)
        let fish = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Fish", frequency: .occasionally)
        let seafood = CategoryValueMO(context: context, categoryId: protein.categoryId, name: "Seefood", frequency: .occasionally)
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
        
        meal(name: "Chickpea Kofta", desc: "Chickpea Kofta", carbs: potato, protein: veggie, cuisine: indian, url: "https://www.hellofresh.co.uk/recipes/indian-style-chickpea-koftas-5f6b39272d47bb2361083f9e", notes: "Source: Hello Fresh")
        meal(name: "Sausage and Mash", desc: "Sausage and Mash", carbs: potato, protein: sausage, cuisine: trad)
        meal(name: "Chicken Stew", desc: "Chicken Stew", carbs: potato, protein: chicken, cuisine: trad, notes: "Source: Hello Fresh")
        meal(name: "Chorizo Crusted Cod", desc: "Chorizo Crusted Cod", carbs: potato, protein: fish, cuisine: med, url: "https://www.hellofresh.co.uk/recipes/cheesy-chorizo-crusted-cod-5f7f1e8b53c3e854b773face")
        meal(name: "Cottage Pie", desc: "Cottage Pie", carbs: potato, protein: beef, cuisine: trad)
        meal(name: "Fish and Chips", desc: "Fish and Chips", carbs: potato, protein: fish, cuisine: trad)
        meal(name: "Chicken pie", desc: "Chicken pie", carbs: potato, protein: chicken, cuisine: trad)
        meal(name: "Thai Salmon Fishcakes", desc: "Thai Salmon Fishcakes", carbs: potato, protein: fish, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/thai-salmon-fishcakes-5efdeefdfc052603c65b2d72/", notes: "Source: Hello Fresh")
        meal(name: "Classic Fish Pie", desc: "Classic Fish Pie", carbs: potato, protein: fish, cuisine: trad, url: "https://www.hellofresh.co.uk/recipes/classic-fish-pie-5c52c90cc445fa1a690be802/", notes: "Source: Hello Fresh")
        meal(name: "Spaghetti Carbonara", desc: "Spaghetti Carbonara", carbs: pasta, protein: pork, cuisine: med)
        meal(name: "Chorizo Sweetcorn Pasta", desc: "Chorizo Sweetcorn Pasta", carbs: pasta, protein: pork, cuisine: med)
        meal(name: "Lemony Chicken Linguine", desc: "Lemony Chicken Linguine", carbs: pasta, protein: chicken, cuisine: med, url: "https://www.hellofresh.co.uk/recipes/lemony-chicken-linguine-5d9cc3d72c871c42d3302068", notes: "Source: Hello Fresh")
        meal(name: "Spag Bog", desc: "Spag Bog", carbs: pasta, protein: beef, cuisine: med)
        meal(name: "Lasagne", desc: "Lasagne", carbs: pasta, protein: beef, cuisine: med)
        meal(name: "Moussaka", desc: "Moussaka", carbs: potato, protein: lamb, cuisine: med)
        meal(name: "Chicken Pasta Bake", desc: "Chicken Pasta Bake", carbs: pasta, protein: chicken, cuisine: med)
        meal(name: "Tortelloni", desc: "Tortelloni", carbs: pasta, protein: veggie, cuisine: med)
        meal(name: "Teriyaki Chicken and Udon noodles", desc: "Teriyaki Chicken and Udon noodles", carbs: pasta, protein: various, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/teriyaki-chicken-and-udon-noodle-stir-fry-5fb502f0114cc510f32a4887")
        meal(name: "Creamy Chicken and Rice", desc: "Creamy Chicken and Rice", carbs: rice, protein: chicken, cuisine: trad)
        meal(name: "Thai Sticky Pork", desc: "Thai Sticky Pork", carbs: rice, protein: pork, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/asian-style-sticky-pork-5f885907fa74936fae3e6a8f/", notes: "Source: Hello Fresh")
        meal(name: "Chicken Korma", desc: "Chicken Korma", carbs: rice, protein: chicken, cuisine: indian, notes: "Source: Jamie Oliver")
        meal(name: "Beef Rogan Josh", desc: "Beef Rogan Josh", carbs: rice, protein: beef, cuisine: indian)
        meal(name: "Hoisin Chicken", desc: "Hoisin Chicken", carbs: rice, protein: chicken, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/hoisin-chicken-stir-fry-59a97249043c3c67eb61a752", notes: "Source: Hello Fresh")
        meal(name: "Lamb Tagine", desc: "Lamb Tagine", carbs: couscous, protein: lamb, cuisine: med)
        meal(name: "Sweet Potato Curry with peanut butter", desc: "Sweet Potato Curry with peanut butter", carbs: rice, protein: veggie, cuisine: indian)
        meal(name: "Sweet and Sour Pork", desc: "Sweet and Sour Pork", carbs: rice, protein: pork, cuisine: oriental)
        meal(name: "Thai style Cauliflower curry", desc: "Thai style Cauliflower curry", carbs: rice, protein: veggie, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/thai-veggie-curry-5f21772553e09073286538e6")
        meal(name: "Coconut dal with butternut squash", desc: "Coconut dal with butternut squash", carbs: rice, protein: veggie, cuisine: indian, url: "https://www.hellofresh.co.uk/recipes/coconut-dal-wk40-598c5f5f0534685d355f40e3")
        meal(name: "Pan-fried Chicken and spicy lentils", desc: "Pan-fried Chicken and spicy lentils", carbs: lentils, protein: chicken, cuisine: trad, url: "https://www.hellofresh.co.uk/recipes/pan-fried-chicken-59022bb799052d5f8c087152", notes: "Source: Hello Fresh")
        meal(name: "Chilli con Carne", desc: "Chilli con Carne", carbs: rice, protein: beef, cuisine: mexican)
        meal(name: "Fajitas", desc: "Fajitas", carbs: bread, protein: chicken, cuisine: mexican)
        meal(name: "Pizza", desc: "Pizza", carbs: bread, protein: various, cuisine: med)
        meal(name: "Enchilladas", desc: "Enchilladas", carbs: bread, protein: beef, cuisine: mexican)
        meal(name: "Crispy Duck", desc: "Crispy Duck", carbs: bread, protein: duck, cuisine: oriental)
        meal(name: "Mango Chicken Wraps", desc: "Mango Chicken Wraps", carbs: bread, protein: chicken, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/mango-chicken-wraps-5da74f55dbf7dc3207510840", notes: "Source: Hello Fresh")
        meal(name: "Pork and Ramen", desc: "Pork and Ramen", carbs: pasta, protein: pork, cuisine: oriental)
        meal(name: "Lime roasted salmon and spicy noodles", desc: "Lime roasted salmon and spicy noodles", carbs: rice, protein: fish, cuisine: oriental, url: "https://www.hellofresh.co.uk/recipes/lime-roasted-salmon-5f885903d6210c62786cba95")
        meal(name: "Pan-fried monkfish with roasted fennel", desc: "Pan-fried monkfish with roasted fennel", carbs: potato, protein: fish, cuisine: med, url: "https://www.hellofresh.co.uk/recipes/pan-fried-monkfish-with-roasted-fennel-601a866c3f5942275a0b31b2")
        meal(name: "Prawn and Squash Dahl", desc: "Prawn and Roasted Butternut Squash Dahl with Spring Onions", carbs: squash, protein: seafood, cuisine: indian, notes: "Source: Hello Fresh")
    }
}
