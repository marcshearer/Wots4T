//
//  Allocation View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 02/02/2021.
//

import Combine
import SwiftUI
import WidgetKit
import CoreData
import UniformTypeIdentifiers

public class AllocationViewModel : ObservableObject, Identifiable, CustomDebugStringConvertible {
    // Properties in core data model
    @Published private(set) var dayNumber: DayNumber!
    @Published private(set) var slot: Int!
    @Published private(set) var meal: MealViewModel!
    @Published private(set) var allocated: Date!
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var allocationMO: AllocationMO?
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Drag and drop ID
    public var itemProvider: NSItemProvider {
        return NSItemProvider(object: AllocationItemProvider(self))
    }
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.allocationMO == nil ||
           self.dayNumber != self.allocationMO!.dayNumber ||
           self.slot != self.allocationMO!.slot ||
           self.meal.mealId != self.allocationMO?.mealId ||
           self.allocated != self.allocationMO?.allocated {
            result = true
        }
        return result
    }
    
    public init(allocationMO: AllocationMO? = nil) {
        self.allocationMO = allocationMO
        self.revert()
        self.setupMappings()
    }
    
    public init(dayNumber: DayNumber, slot: Int = 0, meal: MealViewModel, allocated: Date) {
        self.dayNumber = dayNumber
        self.slot = slot
        self.meal = meal
        self.allocated = allocated
        self.setupMappings()
    }
    
    private func setupMappings() {
        
    }
    
    public func change(dayNumber: DayNumber, slot: Int) {
        if self.dayNumber != dayNumber || self.slot != slot {
            self.dayNumber = dayNumber
            self.slot = slot
            self.allocated = Date()
        }
    }
    
    public func change(meal: MealViewModel) {
        if self.meal.mealId != meal.mealId {
            self.meal = meal
            self.allocated = Date()
        }
    }
    
    private func revert() {
        if let allocationMO = self.allocationMO {
            self.dayNumber = allocationMO.dayNumber
            self.slot = allocationMO.slot
            self.meal = MasterData.shared.meals[allocationMO.mealId]
            self.allocated = allocationMO.allocated
        }
    }
    
    public func save() {
        MasterData.shared.save(allocation: self)
        WidgetCenter.shared.reloadAllTimelines()
        Utility.debugMessage("save", "reloadTimeLines")
    }
    
    public func insert() {
        MasterData.shared.insert(allocation: self)
        WidgetCenter.shared.reloadAllTimelines()
        Utility.debugMessage("insert", "reloadTimeLines")
    }
    
    public func remove() {
        MasterData.shared.remove(allocation: self)
    }
    
    public var description: String {
        "Date: \(self.dayNumber.date.toString()), Slot: \(self.slot ?? 0), Meal: \(self.meal.name)"
    }
    public var debugDescription: String { self.description }
}

@objc final class AllocationItemProvider: NSObject, NSItemProviderReading, NSItemProviderWriting {

    public let dayNumber: DayNumber
    public let slot: Int
    
    init(_ allocation: AllocationViewModel) {
        self.dayNumber = allocation.dayNumber
        self.slot = allocation.slot
    }
    
    init(dayNumber: DayNumber, slot: Int, mealId: UUID?) {
        self.dayNumber = dayNumber
        self.slot = slot
    }
        
    static let itemProviderType: String = "com.sheareronline.wots4T.allocation"
    static let type: String = "allocation"
    
    public static var writableTypeIdentifiersForItemProvider: [String] = [UTType.data.identifier]
    
    public static var readableTypeIdentifiersForItemProvider: [String] = [UTType.data.identifier]
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 1)
        
        do {
            let propertyList: [String:Any?] =
                ["type"         : AllocationItemProvider.type,
                 "dayNumber"    : self.dayNumber.value,
                 "slot"         : self.slot]
        let data = try JSONSerialization.data(withJSONObject: propertyList, options: .prettyPrinted)
            progress.completedUnitCount = 1
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        
        return progress
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws ->AllocationItemProvider {

        let propertyList = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any?]

        if propertyList["type"] as? String == AllocationItemProvider.type {
            return AllocationItemProvider(dayNumber: DayNumber(from: propertyList["dayNumber"] as! Int),
                                          slot:      propertyList["slot"] as! Int,
                                          mealId:    propertyList["mealId"] as? UUID)
        } else {
            throw Wots4TError.invalidData
        }
    }
    
    static public func dropAction(at toDayNumber: DayNumber, _ toSlot: Int, _ items: [NSItemProvider], action: @escaping (DayNumber, Int, AllocationViewModel)->()) {
        for item in items {
            _ = item.loadObject(ofClass: AllocationItemProvider.self) { (from, error) in
                if error == nil {
                    if let from = from as? AllocationItemProvider, let allocation = MasterData.shared.allocations[from.dayNumber]?[from.slot] {
                        action(toDayNumber, toSlot, allocation)
                    }
                }
            }
        }
    }
}

class AllocationDropDelegate: DropDelegate {
    
    private let dayNumber: DayNumber
    private let slot: Int
    private let action: (DayNumber, Int, AllocationViewModel)->()
    
    init(on dayNumber: DayNumber, _ slot: Int, action: @escaping (DayNumber, Int, AllocationViewModel)->()) {
        self.dayNumber = dayNumber
        self.slot = slot
        self.action = action
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let items = info.itemProviders(for: AllocationItemProvider.readableTypeIdentifiersForItemProvider)
        AllocationItemProvider.dropAction(at: self.dayNumber, self.slot, items, action: self.action)
        return true
    }
}
