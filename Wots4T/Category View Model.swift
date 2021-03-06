//
//  Category View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 12/02/2021.
//

import Combine
import SwiftUI
import CoreData

public class CategoryViewModel : ObservableObject, Identifiable, CustomDebugStringConvertible {

    // Properties in core data model
    @Published private(set) var categoryId: UUID!
    @Published public var name: String = ""
    @Published public var importance: Importance = .other
    
    // Linked managed objects - should only be referenced in this and the Data classes
    @Published internal var categoryMO: CategoryMO?
    
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    @Published internal var canExit: Bool = false
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.categoryMO == nil ||
           self.categoryId != self.categoryMO!.categoryId ||
           self.name != self.categoryMO!.name ||
           self.importance != self.importance {
            result = true
        }
        return result
    }
    
    public init() {
        self.categoryId = UUID()
        self.setupMappings()
    }
    
    public init(categoryMO: CategoryMO? = nil) {
        self.categoryMO = categoryMO
        self.revert()
        self.setupMappings()
    }
    
    public init(categoryId: UUID? = nil, name: String, importance: Importance) {
        self.categoryId = categoryId ?? UUID()
        self.name = name
        self.importance = importance
        self.setupMappings()
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "\(categoryName.capitalized) \(categoryNameTitle) must not be left blank. Either enter a valid \(categoryName) \(categoryNameTitle) or delete this \(categoryName)." : (self.nameExists(name) ? "This \(categoryNameTitle) already exists on another \(categoryName)" : ""))
            }
        .assign(to: \.saveMessage, on: self)
        .store(in: &cancellableSet)
        
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (self.nameExists(name) ? "Duplicate \(categoryNameTitle)" : "")
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
        
        Publishers.CombineLatest3($name, $categoryMO, $canSave)
            .receive(on: RunLoop.main)
            .map { (name, categoryMO, canSave) in
                return (canSave || (categoryMO == nil && name == ""))
            }
        .assign(to: \.canExit, on: self)
        .store(in: &cancellableSet)
 
    }
    
    private func revert() {
        if let categoryMO = self.categoryMO {
            self.categoryId = categoryMO.categoryId
            self.name = categoryMO.name
            self.importance = categoryMO.importance
        }
    }
    
    public func save() {
        if self.categoryMO == nil {
            MasterData.shared.insert(category: self)
        } else {
            MasterData.shared.save(category: self)
        }
    }
    
    public func insert() {
        MasterData.shared.insert(category: self)
    }
    
    public func remove() {
        MasterData.shared.remove(category: self)
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !MasterData.shared.categories.compactMap{$1}.filter({$0.name == name && $0.categoryId != self.categoryId}).isEmpty
    }
    
    public var description: String {
        "Category: \(self.name)"
    }
    public var debugDescription: String { self.description }
}
