//
//  Wots4TApp.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import SwiftUI

@main
struct Wots4TApp: App {
    public let context = PersistenceController.shared.container.viewContext

    public static var database: String = "unknown"
    
    init() {
        CoreData.context = context
        MyApp.shared.start()
    }
    
    var body: some Scene {
        
        WindowGroup {
            CalendarView()
        }
    }
}
