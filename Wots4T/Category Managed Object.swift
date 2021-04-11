//
//  Category Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 12/02/2021.
//

import CoreData

@objc(CategoryMO)
public class CategoryMO: NSManagedObject, ManagedObject, Identifiable {

    public static let tableName = "Category"
    
    public var id: UUID { self.categoryId }
    @NSManaged public var categoryId: UUID
    @NSManaged public var name: String
    @NSManaged public var importance16: Int16
    
    convenience init(context: NSManagedObjectContext, categoryId: UUID? = nil, name: String, importance: Importance) {
        self.init(context: context)
        self.categoryId = categoryId ?? UUID()
        self.name = name
        self.importance = importance
    }
    
    public var importance: Importance {
        get { Importance(rawValue: Int(importance16)) ?? .other }
        set { self.importance16 = Int16(newValue.rawValue) }
    }
}
