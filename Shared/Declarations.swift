//
//  Declarations.swift
//  Wots4T
//
//  Created by Marc Shearer on 01/02/2021.
//

import CoreGraphics

// Parameters

public let maxRetention = 366
public let appGroup = "group.com.sheareronline.wots4t" // Has to match entitlements
public let widgetKind = "com.sheareronline.wots4t"

// Localisable names

public let appName = "Wots4T"
public let chooseName = "Choose a Meal"
public let editMealsName = "Meals"
public let editAttachmentsName = "Attachments"
public let editCategoriesName = "Categories"
public let editCategoryValueName = "Edit Value"
public let newCategoryValuesName = "New Value"

public let categoryName = "category"
public let categoryNamePlural = "categories"
public let categoryValueName = "category value"
public let categoryValueNamePlural = "category values"

public let mealName = "meal"
public let mealNamePlural = "meals"
public let mealCategoryValueName = "meal category"
public let mealCategoryValueNamePlural = "meal categories"

public let allocationName = "meal choice"

public let breakfastName = "breakfast"
public let lunchName = "lunch"
public let dinnerName = "dinner"

public let calendarName = "calendar"
public let dateFormat = "EEEE d MMMM"

public let mealNameTitle = "name"
public let mealDescTitle = "description"
public let mealUrlTitle = "web page Link"
public let mealImageTitle = "image"
public let mealNotesTitle = "notes"
public let mealOtherImagesTitle = "other images"

public let categoryNameTitle = "name"
public let categoryImportanceTitle = "importance"
public let categoryValuesTitle = "possible values"

public let categoryValueNameTitle = "name"
public let categoryValueFrequencyTitle = "frequency"

let bannerHeight: CGFloat = (MyApp.target == .macOS ? 60 : 70)

public enum UIMode {
    case uiKit
    case appKit
    case unknown
}

#if canImport(UIKit)
public let target: UIMode = .uiKit
#elseif canImport(appKit)
public let target: UIMode = .appKit
#else
public let target: UIMode = .unknow
#endif

// Enumerations

public enum Importance: Int, Comparable, CaseIterable {
    case highest = 0
    case high = 1
    case medium = 2
    case other = 3
    
    public static func < (lhs: Importance, rhs: Importance) -> Bool {
        return (lhs.rawValue < rhs.rawValue)
    }
    
    public var string: String {
        return "\(self)"
    }
}

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
