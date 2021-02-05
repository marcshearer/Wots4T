//
//  Allocation Managed Object.swift
//  Wots4T
//
//  Created by Marc Shearer on 01/02/2021.
//

import CoreData

@objc(AllocationMO)
public class AllocationMO: NSManagedObject {

    @NSManaged public var dayNumber64: Int64
    @NSManaged public var slot16: Int16
    @NSManaged public var mealId: UUID
    
    convenience init(context: NSManagedObjectContext, dayNumber: DayNumber, slot: Int, mealId: UUID) {
        self.init(context: context)
        self.dayNumber64 = Int64(dayNumber.value)
        self.slot16 = Int16(slot)
        self.mealId = mealId
    }
    
    public var slot: Int {
        get {
            Int(self.slot16)
        }
        set {
            self.slot16 = Int16(newValue)
        }
    }
    
    public var dayNumber: DayNumber {
        get {
            DayNumber(from: Int(self.dayNumber64))
        }
        set {
            self.dayNumber64 = Int64(newValue.value)
        }
    }
}
