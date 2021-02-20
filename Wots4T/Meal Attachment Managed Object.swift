//
//  Meal Attachment Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 19/02/2021.
//

import CoreData

@objc(MealAttachmentMO)
public class MealAttachmentMO: NSManagedObject, Identifiable {

    public static let tableName = "MealAttachment"
    
    public var id: UUID { self.attachmentId }
    @NSManaged public var mealId: UUID
    @NSManaged public var attachmentId: UUID
    @NSManaged public var sequence16: Int16
    @NSManaged public var attachment: Data?
    
    convenience init(context: NSManagedObjectContext, mealId: UUID, attachmentId: UUID?, sequence: Int? = nil, attachment: Data? = nil) {
        self.init(context: context)
        self.mealId = mealId
        self.attachmentId = attachmentId ?? UUID()
        self.sequence = sequence ?? Int(Int16.max)
        self.attachment = attachment
    }
    
    public var sequence: Int {
        get { Int(self.sequence16) }
        set { self.sequence16 = Int16(newValue)}
    }
}
