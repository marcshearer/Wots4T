//
//  Allocation Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 01/02/2021.
//

import CoreData

@objc(AllocationMO)
public class AllocationMO: NSManagedObject {

    public static let tableName = "Allocation"
    
    @NSManaged public var dayNumber64: Int64
    @NSManaged public var slot16: Int16
    @NSManaged public var mealId: UUID
    @NSManaged public var allocated: Date
    
    convenience init(context: NSManagedObjectContext, dayNumber: DayNumber, slot: Int, mealId: UUID, allocated: Date) {
        self.init(context: context)
        self.dayNumber = dayNumber
        self.slot16 = Int16(slot)
        self.mealId = mealId
        self.allocated = allocated
    }
    
    public var slot: Int {
        get { Int(self.slot16) }
        set { self.slot16 = Int16(newValue) }
    }
    
    public var dayNumber: DayNumber {
        get { DayNumber(from: Int(self.dayNumber64)) }
        set { self.dayNumber64 = Int64(newValue.value) }
    }
}
