//
//  IngredientMO+CoreDataClass.swift
//  Wots4T
//
//  Created by Marc Shearer on 19/01/2021.
//
//

import CoreData

@objc(IngredientMO)
public class IngredientMO: NSManagedObject {

    @NSManaged public var mealId: UUID
    @NSManaged public var ingredientId: UUID
    
    convenience init(context: NSManagedObjectContext, mealId: UUID, ingredientID: UUID) {
        self.init(context: context)
        self.mealId = mealId
        self.ingredientId = ingredientId
    }
    
}
