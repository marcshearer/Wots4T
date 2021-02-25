//
//  Category Value View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 12/02/2021.
//

import Combine
import SwiftUI
import CoreData

public enum Frequency: Int, Comparable, CaseIterable {
    case veryOften = 4
    case often = 3
    case occasionally = 2
    case rarely = 1
    case never = 0
    
    public static func < (lhs: Frequency, rhs: Frequency) -> Bool {
        return (lhs.rawValue < rhs.rawValue)
    }

    public var string: String {
        switch self {
        case .veryOften:
            return "very often"
        case .often:
            return "often"
        case .occasionally:
            return "occasionally"
        case .rarely:
            return "rarely"
        default:
            return "never"
        }
    }
}

public class CategoryValueViewModel : ObservableObject, Identifiable {

    // Properties in core data model
    @Published private(set) var categoryId: UUID!
    @Published private(set) var valueId: UUID!
    @Published public var name: String = ""
    @Published public var frequency: Frequency = .often
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var categoryValueMO: CategoryValueMO?
    
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false

    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.categoryValueMO == nil ||
           self.categoryId != self.categoryValueMO!.categoryId ||
           self.valueId != self.categoryValueMO!.valueId ||
           self.name != self.categoryValueMO!.name ||
           self.frequency != self.frequency {
            result = true
        }
        return result
    }
    
    public init(categoryId: UUID) {
        self.categoryId = categoryId
        self.valueId = UUID()
        self.setupMappings()
    }
    
    public init(categoryValueMO: CategoryValueMO? = nil) {
        self.categoryValueMO = categoryValueMO
        self.revert()
        self.setupMappings()
    }
    
    public init(categoryId: UUID, valueId: UUID? = nil, name: String, frequency: Frequency) {
        self.categoryId = categoryId
        self.valueId = valueId ?? UUID()
        self.name = name
        self.frequency = frequency
        self.setupMappings()
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "\(categoryValueName.capitalized) \(categoryValueNameTitle) must not be left blank. Either enter a valid \(categoryValueName) \(categoryValueNameTitle) or delete this \(categoryValueName)." : (self.nameExists(name) ? "This \(categoryValueNameTitle) already exists on another \(categoryValueName)" : ""))
            }
        .assign(to: \.saveMessage, on: self)
        .store(in: &cancellableSet)
        
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (self.nameExists(name) ? "Duplicate \(categoryValueNameTitle)" : "")
            }
        .assign(to: \.nameMessage, on: self)
        .store(in: &cancellableSet)
        
        $saveMessage
            .receive(on: RunLoop.main)
            .map { (nameError) in
                return (nameError == "")
            }
        .assign(to: \.canSave, on: self)
        .store(in: &cancellableSet)
    }
    
    private func revert() {
        if let categoryValueMO = categoryValueMO {
            self.categoryId = categoryValueMO.categoryId
            self.valueId = categoryValueMO.valueId
            self.name = categoryValueMO.name
            self.frequency = categoryValueMO.frequency
        }
    }
    
    public func save() {
        if self.categoryValueMO == nil {
            DataModel.shared.insert(categoryValue: self)
        } else {
            DataModel.shared.save(categoryValue: self)
        }
    }
    
    public func insert() {
        DataModel.shared.insert(categoryValue: self)
    }
    
    public func remove() {
        DataModel.shared.remove(categoryValue: self)
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !(DataModel.shared.categoryValues[self.categoryId ?? UUID()] ?? [:]).compactMap{$1}.filter({$0.name == name && $0.valueId != self.valueId}).isEmpty
    }
}
