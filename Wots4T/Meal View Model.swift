//
//  Meal View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 18/01/2021.
//

import Combine
import SwiftUI
import CoreData

public class MealViewModel : ObservableObject, Identifiable {
    
    // Properties in core data model
    public var id: UUID { self.mealId }
    private(set) var mealId: UUID!
    @Published public var name: String = ""
    @Published public var desc: String = ""
    @Published public var url: String = ""
    @Published public var notes: String = ""
    @Published public var image: Data?
    @Published public var urlImageCache: Data?
    @Published public var lastDate: Date?
    @Published public var debugInfo: String = ""
    @Published public var categoryValues: [UUID : CategoryValueViewModel] = [:]
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var mealMO: MealMO?
    internal var mealCategoryValueMO: [UUID : MealCategoryValueMO] = [:]
    
    // Other properties
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.mealMO == nil ||
           self.name != self.mealMO?.name ||
           self.desc != self.mealMO?.desc ||
           self.url != self.mealMO?.url ||
           self.notes != self.mealMO?.notes ||
           self.image != self.mealMO?.image ||
           self.urlImageCache != self.mealMO?.urlImageCache ||
           self.lastDate != self.mealMO?.lastDate {
            result = true
        } else {
            let categoryMOValues = self.mealCategoryValueMO.mapValues({$0.valueId})
            let categoryModelValues = self.categoryValues.mapValues({$0.valueId})
            if categoryMOValues != categoryModelValues {
                result = true
            }
        }
        return result
    }
    
    public init() {
        self.mealId = UUID()
        self.setupMappings()
    }
    
    public init(mealMO: MealMO? = nil, mealCategoryValueMO: [UUID : MealCategoryValueMO] = [:]) {
        self.mealMO = mealMO
        self.mealCategoryValueMO = mealCategoryValueMO
        self.revert()
        self.setupMappings()
    }
    
    public init(name: String, desc: String = "", url: String = "", notes: String = "", image: Data? = nil) {
        self.mealId = UUID()
        self.name = name
        self.desc = desc
        self.url = url
        self.notes = notes
        self.image = image
        self.setupMappings()
    }
    
    private func setupMappings() {
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (name == "" ? "\(mealName.capitalized) \(mealNameTitle) must not be left blank. Either enter a valid \(mealName) \(mealNameTitle) or delete this \(mealName)." : "")
            }
        .assign(to: \.saveMessage, on: self)
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
        self.mealId = self.mealMO?.mealId ?? UUID()
        if let mealMO = self.mealMO {
            self.name = mealMO.name
            self.desc = mealMO.desc
            self.url = mealMO.url
            self.notes = mealMO.notes
            self.image = mealMO.image
            self.urlImageCache = mealMO.urlImageCache
            self.lastDate = mealMO.lastDate
            self.categoryValues = [:]
        }
        for (categoryId, mealCategoryValueMO) in self.mealCategoryValueMO {
            self.categoryValues[categoryId] = DataModel.shared.categoryValues[mealCategoryValueMO.categoryId]?[mealCategoryValueMO.valueId]
        }
    }
    
    public func save() {
        if self.mealMO == nil {
            DataModel.shared.insert(meal: self)
        } else {
            DataModel.shared.save(meal: self)
        }
    }
    
    public func insert() {
        DataModel.shared.insert(meal: self)
    }
    
    public func remove() {
        DataModel.shared.remove(meal: self)
    }
    
    public func saveimageCache(image: UIImage) {
        if let imageData = image.pngData() {
            self.urlImageCache = imageData
        } else {
            self.urlImageCache = nil
        }
        CoreData.update() {
            self.mealMO?.urlImageCache = self.urlImageCache
        }
    }
}
