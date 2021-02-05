//
//  Meal+CoreDataClass.swift
//  Wots4T
//
//  Created by Marc Shearer on 18/01/2021.
//
//

import CoreData

@objc(MealMO)
public class MealMO: NSManagedObject, Identifiable {

    public var id: UUID { self.mealId }
    @NSManaged public var mealId: UUID
    @NSManaged public var name: String
    @NSManaged public var desc: String?
    @NSManaged public var url: URL?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var lastDate: Date?
    
    convenience init(context: NSManagedObjectContext, mealId: UUID? = nil, name: String, desc: String? = nil, url: URL? = nil, lastDate: Date? = nil) {
        self.init(context: context)
        self.mealId = mealId ?? UUID()
        self.name = name
        self.desc = desc
        self.url = url
        self.lastDate = lastDate
    }
}
