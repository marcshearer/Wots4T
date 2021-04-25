//
//  Master Data.swift
//  Wots4T
//
//  Created by Marc Shearer on 21/01/2021.
//

import Foundation
import CoreData
import Combine

class MasterData: ObservableObject {
    
    public static let shared = MasterData()
    
    @Published private(set) var receivedRemoteUpdates = 0
    @Published private(set) var publishedRemoteUpdates = 0
    // Updated every 10 seconds (unless suspended)
    @Published private(set) var loadedRemoteUpdates = 0
    @Published private var remoteUpdatesSuspended = false
    
    private var observer: NSObjectProtocol?
    
    @Published private(set) var categories: [UUID:CategoryViewModel] = [:]                  // Category ID
    @Published private(set) var categoryValues: [UUID:[UUID:CategoryValueViewModel]] = [:]  // Category ID / Value ID
    
    @Published private(set) var meals: [UUID:MealViewModel] = [:]                           // Meal ID
    
    @Published private(set) var allocations: [DayNumber:[Int:AllocationViewModel]] = [:]    // Day number / Slot
    
    // Auto-cleanup
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        self.observer = NotificationCenter.default.addObserver(forName: Notification.Name.persistentStoreRemoteChangeNotification, object: nil, queue: nil, using: { (notification) in
            Utility.mainThread {
                self.receivedRemoteUpdates += 1
            }
        })
        self.setupMappings()
    }
    
    public func suspendRemoteUpdates(_ suspend: Bool) {
        if suspend != self.remoteUpdatesSuspended {
            self.remoteUpdatesSuspended = suspend
        }
    }
    
    private func setupMappings() {
        Publishers.CombineLatest($receivedRemoteUpdates, $remoteUpdatesSuspended)
            .receive(on: RunLoop.main)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .map { (receivedRemoteUpdates, remoteUpdatesSuspended) in
                return (remoteUpdatesSuspended ? self.publishedRemoteUpdates : receivedRemoteUpdates)
            }
            .sink(receiveValue: { newValue in
                if self.publishedRemoteUpdates != newValue {
                    self.publishedRemoteUpdates = newValue
                }
            })
        .store(in: &cancellableSet)
    }
    
    @discardableResult public func load() -> Int {
        
        let startLoadreceivedRemoteUpdates = self.receivedRemoteUpdates
        
        Utility.debugMessage("MasterData", "Loading \(startLoadreceivedRemoteUpdates)")
        
        /// **Builds in-memory mirror of categories, category value, meals and their category values with pointers to managed objects**
        /// Note that this infers that there will only ever be 1 instance of the app accessing the database
       
        // Read current data
        let categoryList = CoreData.fetch(from: CategoryMO.tableName, sort: (key: #keyPath(CategoryMO.importance16), direction: .ascending)) as! [CategoryMO]
        let categoryValueList = CoreData.fetch(from: CategoryValueMO.tableName, sort: (key: #keyPath(CategoryValueMO.frequency16), direction: .ascending)) as! [CategoryValueMO]
        
        let mealList = CoreData.fetch(from: MealMO.tableName, sort: (key: #keyPath(MealMO.lastDate), direction: .ascending)) as! [MealMO]
        let mealCategoryValueList = CoreData.fetch(from: MealCategoryValueMO.tableName) as! [MealCategoryValueMO]
        let mealAttachmentList = CoreData.fetch(from: MealAttachmentMO.tableName) as! [MealAttachmentMO]
        
        let dateFilter = NSPredicate(format: "dayNumber64 >= %d", DayNumber.today.value - maxRetention)
        var allocationList = CoreData.fetch(from: AllocationMO.tableName, filter: dateFilter, sort: (key: #keyPath(AllocationMO.dayNumber64), direction: .ascending), (key: #keyPath(AllocationMO.slot16), direction: .ascending), (key: #keyPath(AllocationMO.allocated), direction: .ascending)) as! [AllocationMO]
        
        // Check duplicates
        self.checkDuplicates(categoryList, ["categoryId"], descKey: "name", recordName: CategoryMO.tableName)
        self.checkDuplicates(categoryValueList, ["categoryId", "valueId"], recordName: CategoryValueMO.tableName)
        self.checkDuplicates(mealList, ["mealId"], descKey: "name", recordName: MealMO.tableName)
        self.checkDuplicates(mealCategoryValueList, ["mealId", "categoryId", "valueId"], recordName: MealCategoryValueMO.tableName)
        self.checkDuplicates(mealAttachmentList, ["mealId", "attachmentId"], recordName: MealAttachmentMO.tableName)
        self.checkDuplicates(allocationList, ["dayNumber64", "slot16"], recordName: AllocationMO.tableName) { (record) in
            // Delete the earlier duplicate records in the list
            let allocationMO = record as! AllocationMO
            if let index = allocationList.firstIndex(where: {$0.objectID == allocationMO.objectID}) {
                CoreData.update {
                    allocationList.remove(at: index)
                    CoreData.context.delete(allocationMO)
                }
            }
        }
        
       // Setup categories
        self.categories = [:]
        self.categoryValues = [:]
        for category in categoryList {
            let categoryValueMO = categoryValueList.filter( {$0.categoryId == category.categoryId})
            let categoryValues = Dictionary(uniqueKeysWithValues: categoryValueMO.map{($0.valueId, CategoryValueViewModel(categoryValueMO: $0))})
            self.categoryValues[category.categoryId] = categoryValues
            self.categories[category.categoryId] = CategoryViewModel(categoryMO: category)
        }
        
        // Setup meals
        self.meals = [:]
        for mealMO in mealList {
            let mealCategoryValueArray = mealCategoryValueList.filter( { $0.mealId == mealMO.mealId } )
            let mealCategoryValueMO = Dictionary(uniqueKeysWithValues: mealCategoryValueArray.map{($0.categoryId, $0)})
            let mealAttachmentMO = Set(mealAttachmentList.filter( {$0.mealId == mealMO.mealId }))
            self.meals[mealMO.mealId] = MealViewModel(mealMO: mealMO, mealCategoryValueMO: mealCategoryValueMO, mealAttachmentMO: mealAttachmentMO)
        }

        //Setup calendar
        self.allocations = [:]
        for allocationMO in allocationList {
            self.addAllocation(allocation: AllocationViewModel(allocationMO: allocationMO))
        }
        
        if startLoadreceivedRemoteUpdates == self.receivedRemoteUpdates {
            // No additional changes since start
            self.loadedRemoteUpdates = self.receivedRemoteUpdates
            return self.loadedRemoteUpdates
        } else {
            // Things have moved since load started - reload
            return self.load()
        }
    }
    
    /// Method to check for duplicates
    
    private func checkDuplicates(_ records: [NSManagedObject], _ indexKeys: [String], descKey: String? = nil, recordName: String, action: ((NSManagedObject)->())? = nil) {
        // Note that if the delete flag is set then the earlier entry(ies) in the list will be deleted
        // Therefore the list should be sorted so that the entries to be deleted appear earlier
        // If the delete flag is not set and a duplicate is detected this will result in a fatal error
        
        if records.count > 1 {
        
            var lastKey: [String:Any?] = [:]
            
            let entity = records.first!.entity
            let attributes = entity.attributesByName
            
            func checkKey(record: NSManagedObject, key: String) -> Bool {
                var same = true
                switch attributes[key]?.attributeType {
                case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
                    let value = record.value(forKey: key) as? Int
                    if value != (lastKey[key] as? Int) {
                        same = false
                    }
                    lastKey[key] = value
                case .UUIDAttributeType:
                    let value = record.value(forKey: key) as? UUID
                    if value != (lastKey[key] as? UUID) {
                        same = false
                    }
                    lastKey[key] = value
                default:
                    fatalError("Core data type not handled")
                }
                return same
            }
            
            for record in records.reversed() {
                var duplicate = true
                for indexKey in indexKeys {
                    let keySame = checkKey(record: record, key: indexKey)
                    duplicate = duplicate && keySame
                }
                if duplicate {
                    var desc: String
                    if let descKey = descKey {
                        desc = record.value(forKey: descKey) as! String
                    } else {
                        desc = "Unknown"
                    }
                    if let action = action {
                        action(record)
                    } else {
                        fatalError("Duplicate key for record \(desc)!) in table \(recordName)")
                    }
                }
            }
        }
    }
    
    /// Methods to sort the meals
    
    public func sortedMeals(dayNumber: DayNumber! = nil) -> [MealViewModel] {
        let categories = self.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance.rawValue, $0.name], [$1.importance.rawValue, $1.name], [.int, .string])})
        var weightings: [UUID:[UUID:Int]] = [:] // categoryId/valueId
        
        // Flatten out allocation dictionaries - note this should be possible with a couple of compactMaps
        var unsorted: [AllocationViewModel] = []
        for (_, dayAllocations) in self.allocations {
            for (_, allocation) in dayAllocations {
                unsorted.append(allocation)
            }
        }
        // Now sort into reverse chronological order
        let allocations = unsorted.sorted(by: {Utility.lessThan([$1.dayNumber.value, $1.slot], [$0.dayNumber.value, $0.slot])})
        
        for category in categories {
            weightings[category.categoryId] = [:]
            
            for (_, value) in self.categoryValues[category.categoryId] ?? [:] {
                if let dayNumber = dayNumber {
                    // Compute weighting for each category value based on days from nearest occurrence of that value times the frequency of that value
                    var foundBefore = false
                    var index = 0
                    
                    while !foundBefore && index < allocations.count {
                        let allocation = allocations[index]
                        if let meal = self.meals[allocation.meal.mealId] {
                            if let mealValue = meal.categoryValues[category.categoryId] {
                                if mealValue.valueId == value.valueId {
                                    let distance = abs(allocation.dayNumber - dayNumber)
                                    let weighting = distance * value.frequency.rawValue
                                    if weighting < (weightings[category.categoryId]![value.valueId] ?? maxRetention + 1) {
                                        weightings[category.categoryId]![value.valueId] = weighting
                                        foundBefore = allocation.dayNumber < dayNumber
                                    }
                                }
                            }
                        }
                        index += 1
                    }
                    if weightings[category.categoryId]![value.valueId] == nil {
                        // Not previously allocated - default to max retention * factor
                        weightings[category.categoryId]![value.valueId] = value.frequency.rawValue * (maxRetention + 1)
                    }
                    
                } else {
                    // Simply base sort on the frequencies
                    weightings[category.categoryId]![value.valueId] = value.frequency.rawValue
                }
            }
        }
        
        // Now build a sort array from the category weightings for each meal and sort
        var sort: [(weightings: [Any], meal: MealViewModel)] = []
        for (_, meal) in self.meals {
            var mealWeightings: [Any] = []
            for category in categories {
                if let mealValueId = meal.categoryValues[category.categoryId]?.valueId {
                    mealWeightings.append(weightings[category.categoryId]?[mealValueId] ?? maxRetention + 1)
                } else {
                    mealWeightings.append(0)
                }
            }
            if dayNumber != nil {
                if let mostRecent = allocations.first(where: {$0.meal.mealId == meal.mealId}) {
                    mealWeightings.append(abs(mostRecent.dayNumber - dayNumber))
                } else {
                    mealWeightings.append(maxRetention + 1)
                }
            }
            mealWeightings.append(meal.name)
            sort.append((weightings: mealWeightings, meal: meal))
        }
        var types: [Utility.SortType] = []
        for _ in categories {
            types.append(.int)
        }
        if dayNumber != nil {
            types.append(.int)
        }
        types.append(.string)
        let sorted = sort.sorted(by: { Utility.lessThan($1.weightings, $0.weightings, types) })
        return sorted.map{$0.meal}
    }
    
    /// Methods for meals and Categorys
    
    public func insert(meal: MealViewModel) {
        assert(meal.mealMO == nil && meal.mealCategoryValueMO.isEmpty, "Cannot insert a \(mealName) which already has managed objects")
        assert(self.meals[meal.mealId] == nil, "\(mealName) already exists and cannot be created")
        CoreData.update(updateLogic: {
            meal.mealMO = MealMO(context: CoreData.context, mealId: meal.mealId, name: meal.name, desc: meal.desc, lastDate: meal.lastDate)
            self.updateMO(meal: meal)
            self.meals[meal.mealId] = meal
        })
    }
    
    public func remove(meal: MealViewModel) {
        assert(meal.mealMO != nil, "Cannot remove a \(mealName) which doesn't already have managed objects")
        assert(self.meals[meal.mealId] != nil, "\(mealName) does not exist and cannot be deleted")
        CoreData.update(updateLogic: {
            // Remove meal category values
            if !meal.mealCategoryValueMO.isEmpty {
                self.updateMealCategoryValuesMO(meal: meal, categoryValues: [:])
            }
            
            // Remove attachments
            if !meal.mealAttachmentMO.isEmpty {
                self.updateMealAttachmentsMO(meal: meal, attachments: [])
            }
            
            // Remove any allocations for this meal
            let mealAllocations = (allocations.compactMap{$1.compactMap{$1}}).flatMap{$0}.filter{$0.meal.mealId == meal.mealId}
            for allocation in mealAllocations {
                self.remove(allocation: allocation)
            }
            
            // Now remove the meal itself
            CoreData.context.delete(meal.mealMO!)
            self.meals[meal.mealId] = nil
        })
    }
    
    public func save(meal: MealViewModel) {
        assert(meal.mealMO != nil, "Cannot save a \(mealName) which doesn't already have managed objects")
        assert(self.meals[meal.mealId] != nil, "\(mealName) does not exist and cannot be updated")
        if meal.changed {
            CoreData.update(updateLogic: {
                self.updateMO(meal: meal)
                self.updateMealCategoryValuesMO(meal: meal)
                self.updateMealAttachmentsMO(meal: meal)
            })
        }
    }
    
    private func updateMO(meal: MealViewModel) {
        meal.mealMO!.mealId = meal.mealId
        meal.mealMO!.name = meal.name
        meal.mealMO!.desc = meal.desc
        meal.mealMO!.url = meal.url
        meal.mealMO!.urlImageCache = meal.urlImageCache
        meal.mealMO!.notes = meal.notes
        meal.mealMO!.image = meal.image
        meal.mealMO!.lastDate = meal.lastDate
    }
    
    private func updateMealCategoryValuesMO(meal: MealViewModel, categoryValues: [UUID:CategoryValueViewModel]? = nil) {
        let categoryValues = categoryValues ?? meal.categoryValues
        // First remove any MOs in MO but not in category values
        for (categoryId, mealCategoryValueMO) in meal.mealCategoryValueMO {
            if categoryValues[categoryId]?.valueId != mealCategoryValueMO.valueId {
                meal.mealCategoryValueMO[categoryId] = nil
                CoreData.delete(record: mealCategoryValueMO)

            }
        }
        // Now add any MOs in category values but not in MO
        if !categoryValues.isEmpty {
            for (categoryId, categoryValue) in categoryValues {
                if meal.mealCategoryValueMO[categoryId]?.valueId != categoryValue.valueId {
                    let mealCategoryValueMO = MealCategoryValueMO(context: CoreData.context, mealId: meal.mealId, categoryId: categoryValue.categoryId, valueId: categoryValue.valueId)
                    meal.mealCategoryValueMO[categoryId] = mealCategoryValueMO
                }
            }
        }
    }
    
    private func updateMealAttachmentsMO(meal: MealViewModel, attachments: [AttachmentViewModel]? = nil) {
        let attachments = attachments ?? meal.attachments
        
        // First remove any MOs in MO but not in category values
        for mealAttachmentMO in meal.mealAttachmentMO {
            if attachments.first(where: {$0.attachmentId == mealAttachmentMO.attachmentId}) == nil {
                meal.mealAttachmentMO.remove(mealAttachmentMO)
                CoreData.delete(record: mealAttachmentMO)
            }
        }
        
        // Now update (or add) MOs from attachments
        for attachment in attachments {
            if let mealAttachmentMO = meal.mealAttachmentMO.first(where: {$0.attachmentId == attachment.attachmentId}) {
                mealAttachmentMO.sequence = attachment.sequence
                mealAttachmentMO.attachment = attachment.attachment
            } else {
                meal.mealAttachmentMO.insert(MealAttachmentMO(context: CoreData.context, mealId: meal.mealId, attachmentId: attachment.attachmentId, sequence: attachment.sequence, attachment: attachment.attachment))
            }
        }
    }
    
    /// Methods for allocations
    
    public func insert(allocation: AllocationViewModel) {
        assert(allocation.allocationMO == nil, "Cannot insert a \(allocationName) which already has a managed object")
        assert(self.allocations[allocation.dayNumber]?[allocation.slot] == nil, "\(allocationName) already exists and cannot be created")
        CoreData.update(updateLogic: {
            allocation.allocationMO = AllocationMO(context: CoreData.context, dayNumber: allocation.dayNumber, slot: allocation.slot, mealId: allocation.meal.mealId, allocated: allocation.allocated)
            self.updateMO(allocation: allocation)
            self.addAllocation(allocation: allocation)
        })
    }
    
    public func remove(allocation: AllocationViewModel) {
        assert(allocation.allocationMO != nil, "Cannot remove a \(allocationName) which doesn't already have a managed object")
        assert(self.allocations[allocation.dayNumber]?[allocation.slot] != nil, "\(allocationName) does not exist and cannot be removed")
        CoreData.update(updateLogic: {
            CoreData.context.delete(allocation.allocationMO!)
            self.allocations[allocation.dayNumber]?[allocation.slot] = nil
        })
    }
    
    public func save(allocation: AllocationViewModel) {
        assert(allocation.allocationMO != nil, "Cannot save a \(allocationName) which doesn't already have managed objects")
        if allocation.changed {
            CoreData.update(updateLogic: {
                self.updateMO(allocation: allocation)
            })
        }
    }
    
    private func updateMO(allocation: AllocationViewModel) {
        allocation.allocationMO!.dayNumber = allocation.dayNumber
        allocation.allocationMO!.slot = allocation.slot
        allocation.allocationMO!.mealId = allocation.meal.mealId
        allocation.allocationMO!.allocated = allocation.allocated
    }
    
    private func addAllocation(allocation: AllocationViewModel) {
        if self.allocations[allocation.dayNumber] == nil {
            self.allocations[allocation.dayNumber] = [:]
        }
        self.allocations[allocation.dayNumber]![allocation.slot] = allocation
    }
    
    /// Methods for categories
    
    public func insert(category: CategoryViewModel) {
        assert(category.categoryMO == nil, "Cannot insert a \(categoryName) which already has a managed object")
        assert(self.categories[category.categoryId] == nil, "\(categoryName) already exists and cannot be created")
        CoreData.update(updateLogic: {
            category.categoryMO = CategoryMO(context: CoreData.context, categoryId: category.categoryId, name: category.name, importance: category.importance)
            self.updateMO(category: category)
            self.categories[category.categoryId] = category
        })
    }
    
    public func remove(category: CategoryViewModel) {
        assert(category.categoryMO != nil, "Cannot remove a \(categoryName) which doesn't already have a managed object")
        assert(self.categories[category.categoryId] != nil, "\(categoryName) does not exist and cannot be deleted")
        CoreData.update(updateLogic: {
            
            // Remove any values for this category
            if let categoryValues = self.categoryValues[category.categoryId] {
                for (_, categoryValue) in categoryValues {
                    self.remove(categoryValue: categoryValue)
                }
            }
            
            // Now remove this category from any meals
            let meals = self.meals.filter{$1.categoryValues[category.categoryId] != nil}
            for (_, meal) in meals {
                meal.categoryValues[category.categoryId] = nil
                meal.save()
            }
            
            // Noew remove the category itself
            CoreData.context.delete(category.categoryMO!)
            self.categories[category.categoryId] = nil
        })
    }
    
    public func save(category: CategoryViewModel) {
        assert(category.categoryMO != nil, "Cannot save a \(categoryName) which doesn't already have managed objects")
        assert(self.categories[category.categoryId] != nil, "\(categoryName) does not exist and cannot be updated")
        if category.changed {
            CoreData.update(updateLogic: {
                self.updateMO(category: category)
            })
        }
    }
    
    private func updateMO(category: CategoryViewModel) {
        category.categoryMO!.categoryId = category.categoryId
        category.categoryMO!.name = category.name
        category.categoryMO!.importance = category.importance
    }
    
    /// Methods for category values
    
    public func insert(categoryValue: CategoryValueViewModel) {
        assert(categoryValue.categoryValueMO == nil, "Cannot insert a \(categoryValueName) which already has a managed object")
        assert(self.categoryValues[categoryValue.categoryId]?[categoryValue.valueId] == nil, "\(categoryValueName) already exists and cannot be created")
        CoreData.update(updateLogic: {
            categoryValue.categoryValueMO = CategoryValueMO(context: CoreData.context, categoryId: categoryValue.categoryId, valueId: categoryValue.valueId, name: categoryValue.name, frequency: categoryValue.frequency)
            self.updateMO(categoryValue: categoryValue)
            self.addCategoryValue(categoryValue: categoryValue)
        })
    }
    
    public func remove(categoryValue: CategoryValueViewModel) {
        assert(categoryValue.categoryValueMO != nil, "Cannot remove a \(categoryValueName) which doesn't already have a managed object")
        assert(self.categoryValues[categoryValue.categoryId]?[categoryValue.valueId] != nil, "\(categoryValueName) does not exist and cannot be deleted")
        CoreData.update(updateLogic: {
            CoreData.context.delete(categoryValue.categoryValueMO!)
            self.categoryValues[categoryValue.categoryId]?[categoryValue.valueId] = nil
        })
    }
    
    public func save(categoryValue: CategoryValueViewModel) {
        assert(categoryValue.categoryValueMO != nil, "Cannot save a \(categoryValueName) which doesn't already have managed objects")
        assert(self.categoryValues[categoryValue.categoryId]?[categoryValue.valueId] != nil, "\(categoryValueName) does not exist and cannot be updated")
        if categoryValue.changed {
            CoreData.update(updateLogic: {
                self.updateMO(categoryValue: categoryValue)
            })
        }
    }
    
    private func updateMO(categoryValue: CategoryValueViewModel) {
        categoryValue.categoryValueMO!.categoryId = categoryValue.categoryId
        categoryValue.categoryValueMO!.valueId = categoryValue.valueId
        categoryValue.categoryValueMO!.name = categoryValue.name
        categoryValue.categoryValueMO!.frequency = categoryValue.frequency
    }
    
    private func addCategoryValue(categoryValue: CategoryValueViewModel) {
        if self.categoryValues[categoryValue.categoryId] == nil {
            self.categoryValues[categoryValue.categoryId] = [:]
        }
        self.categoryValues[categoryValue.categoryId]![categoryValue.valueId] = categoryValue
    }
}

extension Notification.Name {
    static let persistentStoreRemoteChangeNotification = Notification.Name(rawValue: "NSPersistentStoreRemoteChangeNotification")
}

