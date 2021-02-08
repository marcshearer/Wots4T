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
    @Published public var name: String!
    @Published public var desc: String!
    @Published public var url: String!
    @Published public var notes: String!
    @Published public var image: Data?
    @Published public var urlImageCache: Data?
    @Published public var lastDate: Date?
    @Published public var ingredients: Set<UUID>!
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var mealMO: MealMO?
    internal var mealIngredientMO: Set<MealIngredientMO> = []
    
    // Other properties
    @Published private(set) var nameError: String = ""
    @Published private(set) var canSave: Bool = false
    
    var mirror: Mirror!

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
            let ingredients = Set(self.mealIngredientMO.map({$0.ingredientId}))
            if self.ingredients != ingredients {
                result = true
            }
        }
        return result
    }
    
    public init(mealMO: MealMO? = nil, ingredientMO: Set<MealIngredientMO> = []) {
        self.mealMO = mealMO
        self.mealIngredientMO = ingredientMO
        self.revert()
        self.setupMappings()
    }
    
    public init(name: String, desc: String? = "", url: String? = "", notes: String? = "", image: Data? = nil) {
        self.mealId = UUID()
        self.name = name
        self.desc = desc
        self.url = url
        self.notes = notes
        self.image = image
    }
    
    private func setupMappings() {
        mirror = Mirror(reflecting: self)
    }
    
    private func revert() {
        self.mealId = mealMO?.mealId ?? UUID()
        self.name = self.mealMO?.name
        self.desc = self.mealMO?.desc
        self.url = self.mealMO?.url
        self.notes = self.mealMO?.notes
        self.image = self.mealMO?.image
        self.urlImageCache = self.mealMO?.urlImageCache
        self.lastDate = self.mealMO?.lastDate
        self.ingredients = []
        for ingredient in self.mealIngredientMO {
            self.ingredients.insert(ingredient.ingredientId)
        }
    }
    
    public func save() {
        DataModel.shared.save(meal: self)
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
