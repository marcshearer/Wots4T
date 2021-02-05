//
//  Wots4TApp.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import SwiftUI

@main
struct Wots4TApp: App {
    let context = PersistenceController.shared.container.viewContext

    init() {
        CoreData.context = context
        DataModel.shared.load()
    }
    
    var body: some Scene {
        
        WindowGroup {
            CalendarView()
        }
    }
}
