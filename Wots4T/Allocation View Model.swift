//
//  Allocation View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 02/02/2021.
//

import Combine
import SwiftUI
import CoreData

public class AllocationViewModel : ObservableObject, Identifiable {

    // Properties in core data model
    @Published private(set) var dayNumber: DayNumber!
    @Published private(set) var slot: Int!
    @Published private(set) var meal: MealViewModel!
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var allocationMO: AllocationMO?
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.allocationMO == nil ||
           self.dayNumber == self.allocationMO!.dayNumber ||
           self.slot != self.allocationMO!.slot ||
           self.meal.mealId != self.allocationMO?.mealId {
            result = true
        }
        return result
    }
    
    public init(allocationMO: AllocationMO? = nil) {
        self.allocationMO = allocationMO
        self.revert()
        self.setupMappings()
    }
    
    public init(dayNumber: DayNumber, slot: Int = 0, meal: MealViewModel) {
        self.dayNumber = dayNumber
        self.slot = slot
        self.meal = meal
        self.setupMappings()
    }
    
    private func setupMappings() {
        
    }
    
    private func revert() {
        self.dayNumber = self.allocationMO?.dayNumber
        self.slot = self.allocationMO?.slot
        if let meal = DataModel.shared.meals.first(where: {$0.mealId == self.allocationMO?.mealId}) {
            self.meal = meal
        }
    }
    
    public func save() {
        DataModel.shared.save(allocation: self)
    }
    
    public func insert() {
        DataModel.shared.insert(allocation: self)
    }
    
    public func remove() {
        DataModel.shared.remove(allocation: self)
    }
}
