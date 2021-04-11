//
//  Meal View Model.swift
//  Wots4T
//
//  Created by Marc Shearer on 18/01/2021.
//

import Combine
import SwiftUI
import CoreData

public class MealViewModel : ObservableObject, Identifiable, CustomDebugStringConvertible {
    
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
    @Published public var attachments: [AttachmentViewModel] = []
    
    // Linked managed objects - should only be referenced in this and the Data classes
    @Published internal var mealMO: MealMO?
    internal var mealCategoryValueMO: [UUID : MealCategoryValueMO] = [:]            // categoryId
    internal var mealAttachmentMO: Set<MealAttachmentMO> = []
    
    // Other properties
    @Published public var nameMessage: String = ""
    @Published private(set) var saveMessage: String = ""
    @Published private(set) var canSave: Bool = false
    @Published internal var canExit: Bool = false
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []
    
    // Check if view model matches managed object
    public var changed: Bool {
        var result = false
        if self.mealMO == nil ||
           self.mealId != self.mealMO?.mealId ||
           self.name != self.mealMO?.name ||
           self.desc != self.mealMO?.desc ||
           self.url != self.mealMO?.url ||
           self.notes != self.mealMO?.notes ||
           self.image != self.mealMO?.image ||
           self.urlImageCache != self.mealMO?.urlImageCache ||
           self.lastDate != self.mealMO?.lastDate {
            result = true
        } else {
            // Basic data OK - check category values
            let categoryMOValues = self.mealCategoryValueMO.mapValues({$0.valueId})
            let categoryModelValues = self.categoryValues.mapValues({$0.valueId})
            if categoryMOValues != categoryModelValues {
                result = true
            } else {
                // Category values OK - check attachments
                let attachmentMOValues = Set(self.mealAttachmentMO.map({ AttachmentViewModel(attachmentId: $0.attachmentId, sequence: $0.sequence, attachment: $0.attachment) }))
                if attachmentMOValues != Set(self.attachments) {
                    result = true
                }
            }
        }
        return result
    }
    
    public init() {
        self.mealId = UUID()
        self.setupMappings()
    }
    
    public init(mealMO: MealMO? = nil, mealCategoryValueMO: [UUID : MealCategoryValueMO] = [:], mealAttachmentMO: Set<MealAttachmentMO> = []) {
        self.mealMO = mealMO
        self.mealCategoryValueMO = mealCategoryValueMO
        self.mealAttachmentMO = mealAttachmentMO
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
                return (name == "" ? "\(mealName.capitalized) \(mealNameTitle) must not be left blank. Either enter a valid \(mealName) \(mealNameTitle) or delete this \(mealName)." : (self.nameExists(name) ? "This \(mealNameTitle) already exists on another \(mealName)" : ""))
            }
        .assign(to: \.saveMessage, on: self)
        .store(in: &cancellableSet)
        
        $name
            .receive(on: RunLoop.main)
            .map { (name) in
                return (self.nameExists(name) ? "Duplicate \(mealNameTitle)" : "")
            }
        .assign(to: \.nameMessage, on: self)
        .store(in: &cancellableSet)
        
        $saveMessage
            .receive(on: RunLoop.main)
            .map { (saveMessage) in
                return (saveMessage == "")
            }
        .assign(to: \.canSave, on: self)
        .store(in: &cancellableSet)
        
        Publishers.CombineLatest3($name, $mealMO, $canSave)
            .receive(on: RunLoop.main)
            .map { (name, mealMO, canSave) in
                return (canSave || (mealMO == nil && name == ""))
            }
        .assign(to: \.canExit, on: self)
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
        // Set up dictionary of category values
        for (categoryId, mealCategoryValueMO) in self.mealCategoryValueMO {
            self.categoryValues[categoryId] = MasterData.shared.categoryValues[mealCategoryValueMO.categoryId]?[mealCategoryValueMO.valueId]
        }
        // Set up array of attachments
        self.attachments = self.mealAttachmentMO.map({ AttachmentViewModel(attachmentId: $0.attachmentId, sequence: $0.sequence, attachment: $0.attachment) }).sorted(by: { $0.sequence < $1.sequence })
    }
    
    public func save() {
        if self.mealMO == nil {
            MasterData.shared.insert(meal: self)
        } else {
            MasterData.shared.save(meal: self)
        }
    }
    
    public func insert() {
        MasterData.shared.insert(meal: self)
    }
    
    public func remove() {
        MasterData.shared.remove(meal: self)
    }
    
    internal func saveimageCache(image: MyImage?) {
        if let image = image, let imageData = image.pngData() {
            self.urlImageCache = imageData
        } else {
            self.urlImageCache = nil
        }
        CoreData.update() {
            self.mealMO?.urlImageCache = self.urlImageCache
        }
    }
    
    private func nameExists(_ name: String) -> Bool {
        return !MasterData.shared.meals.compactMap{$1}.filter({$0.name == name && $0.mealId != self.mealId}).isEmpty
    }
    
    public var description: String {
        "Meal: \(self.name)"
    }
    public var debugDescription: String { self.description }
}
