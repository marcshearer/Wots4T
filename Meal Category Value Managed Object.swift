//
//  Meal Category Value Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 19/01/2021.
//

import CoreData

@objc(MealCategoryValueMO)
public class MealCategoryValueMO: NSManagedObject, Identifiable {

    public static let tableName = "MealCategoryValue"
    
    public var id: UUID { self.valueId }
    @NSManaged public var mealId: UUID
    @NSManaged public var categoryId: UUID
    @NSManaged public var valueId: UUID
    
    convenience init(context: NSManagedObjectContext, mealId: UUID, categoryId: UUID, valueId: UUID? = nil) {
        self.init(context: context)
        self.mealId = mealId
        self.categoryId = categoryId
        self.valueId = valueId ?? UUID()
    }
}
