//
//  Category Value Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 12/02/2021.
//

import CoreData

@objc(CategoryValueMO)
public class CategoryValueMO: NSManagedObject, ManagedObject, Identifiable {

    public static let tableName = "CategoryValue"
    
    public var id: UUID { self.valueId }
    @NSManaged public var categoryId: UUID
    @NSManaged public var valueId: UUID
    @NSManaged public var name: String
    @NSManaged public var frequency16: Int16
    
    convenience init(context: NSManagedObjectContext, categoryId: UUID, valueId: UUID? = nil, name: String, frequency: Frequency) {
        self.init(context: context)
        self.categoryId = categoryId
        self.valueId = valueId ?? UUID()
        self.name = name
        self.frequency = frequency
    }
    
    public var frequency: Frequency {
        get { Frequency(rawValue: Int(self.frequency16)) ?? .never }
        set { self.frequency16 = Int16(newValue.rawValue)}
    }
    
}
