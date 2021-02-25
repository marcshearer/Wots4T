//
//  Utility Extension.swift
//  Wots4T
//
//  Created by Marc Shearer on 24/02/2021.
//

import CoreGraphics

extension Utility {

    enum SortType {
        case int
        case string
        case float
    }
    
    public static func lessThan (_ lhs: [Int], _ rhs: [Int], element: Int = 0) -> Bool {
        if element >= rhs.count {
            return false
        } else if element >= lhs.count {
            return true
        } else {
            if lhs[element] < rhs[element] {
                return true
            } else if lhs[element] > rhs[element] {
                return false
            } else {
                return Utility.lessThan(lhs, rhs, element: element + 1)
            }
        }
    }
    
    public static func lessThan (_ lhs: [String], _ rhs: [String], element: Int = 0) -> Bool {
        if element >= rhs.count {
            return false
        } else if element >= lhs.count {
            return true
        } else {
            if lhs[element] < rhs[element] {
                return true
            } else if lhs[element] > rhs[element] {
                return false
            } else {
                return Utility.lessThan(lhs, rhs, element: element + 1)
            }
        }
    }
    
    public static func lessThan (_ lhs: [Any], _ rhs: [Any], _ type: [SortType], element: Int = 0) -> Bool {
        if element >= rhs.count {
            return false
        } else if element >= lhs.count {
            return true
        } else {
            switch type[element] {
            case .int:
                let lhsInt = lhs[element] as! Int
                let rhsInt = rhs[element] as! Int
                if lhsInt < rhsInt {
                    return true
                } else if lhsInt > rhsInt {
                    return false
                } else {
                    return Utility.lessThan(lhs, rhs, type, element: element + 1)
                }
            case .float:
                let lhsFloat = lhs[element] as! CGFloat
                let rhsFloat = rhs[element] as! CGFloat
                if lhsFloat < rhsFloat {
                    return true
                } else if lhsFloat > rhsFloat {
                    return false
                } else {
                    return Utility.lessThan(lhs, rhs, type, element: element + 1)
                }
            case .string:
                let lhsString = lhs[element] as! String
                let rhsString = rhs[element] as! String
                if lhsString < rhsString {
                    return true
                } else if lhsString > rhsString {
                    return false
                } else {
                    return Utility.lessThan(lhs, rhs, type, element: element + 1)
                }
            }
        }
    }
        
}
