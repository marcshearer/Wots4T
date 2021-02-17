//
//  Day Number.swift
//  Wots4T
//
//  Created by Marc Shearer on 03/02/2021.
//

import Foundation

public class DayNumber: CustomStringConvertible, Equatable, Comparable, Hashable {
 
    static let today = DayNumber(from: Date())
    static let dayNumber1Jan1970: Int = 2440587
    static let secondsPerDay: Int = 24*60*60
    
    private(set) var value: Int
    
    init(from date: Date) {
        let daysSince1970 = Int((date.timeIntervalSince1970 / Double(DayNumber.secondsPerDay)).rounded(.down))
        self.value = daysSince1970 + DayNumber.dayNumber1Jan1970
    }
    
    init(from value: Int) {
        self.value = value
    }
    
    public var date: Date {
        let daysSince1970 = self.value - DayNumber.dayNumber1Jan1970
        return Date(timeIntervalSince1970: TimeInterval(daysSince1970 * DayNumber.secondsPerDay))
    }
    
    public var description: String { return "\(self.value)" }
    
    public static func + (lhs: DayNumber, rhs: Int) -> DayNumber {
        return DayNumber(from: lhs.value + rhs)
    }
    
    public static func - (lhs: DayNumber, rhs: Int) -> DayNumber {
        return DayNumber(from: lhs.value - rhs)
    }
    
    public static func - (lhs: DayNumber, rhs: DayNumber) -> Int {
        return lhs.value - rhs.value
    }
    
    public static func == (lhs: DayNumber, rhs: DayNumber) -> Bool {
        return lhs.value == rhs.value
    }
    
    public static func < (lhs: DayNumber, rhs: DayNumber) -> Bool {
        return lhs.value < rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}
