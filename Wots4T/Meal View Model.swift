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
    @Published private(set) var name: String!
    @Published private(set) var desc: String!
    @Published private(set) var url: URL!
    @Published private(set) var thumbnail: Data?
    @Published private(set) var lastDate: Date?
    @Published private(set) var ingredients: Set<UUID>!
    
    // Linked managed objects - should only be referenced in this and the Data classes
    internal var mealMO: MealMO?
    internal var ingredientMO: Set<IngredientMO>
    
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
           self.thumbnail != self.mealMO?.thumbnail ||
           self.lastDate != self.mealMO?.lastDate {
            result = true
        } else {
            let ingredients = Set(self.ingredientMO.map({$0.ingredientId}))
            if self.ingredients != ingredients {
                result = true
            }
        }
        return result
    }
    
    public init(mealMO: MealMO? = nil, ingredientMO: Set<IngredientMO> = []) {
        self.mealMO = mealMO
        self.ingredientMO = ingredientMO
        self.revert()
        self.setupMappings()
    }
    
    private func setupMappings() {
        mirror = Mirror(reflecting: self)
    }
    
    private func revert() {
        self.mealId = mealMO?.mealId ?? UUID()
        self.name = self.mealMO?.name ?? ""
        self.desc = self.mealMO?.desc
        self.url = self.mealMO?.url
        self.thumbnail = self.mealMO?.thumbnail
        self.lastDate = self.mealMO?.lastDate
        self.ingredients = []
        for ingredient in self.ingredientMO {
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
    
    public func saveThumbnail(image: UIImage) {
        if let imageData = image.pngData() {
            self.thumbnail = imageData
        } else {
            self.thumbnail = nil
        }
        CoreData.update() {
            self.mealMO?.thumbnail = self.thumbnail
        }
    }
}
