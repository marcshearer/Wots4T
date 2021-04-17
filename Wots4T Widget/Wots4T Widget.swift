//
//  Wots4T Widget.swift
//  Wots4T Widget Extension
//
//  Created by Marc Shearer on 15/04/2021.
//

import WidgetKit
import SwiftUI

@main
struct Wots4TWidget: Widget {
    let kind: String = widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Wots4TWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wots4T")
        .description("Menu for coming days")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Provider: TimelineProvider {
    
    init() {
        // Set up core data stack
        CoreData.context = PersistenceController.shared.container.viewContext
        MyApp.shared.start()
    }
    
    func placeholder(in context: Context) -> Wots4TWidgetEntry {
        Wots4TWidgetEntry(date: Date(), allocations: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (Wots4TWidgetEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Generate a timeline for today
        let entries = [getEntry()]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getEntry() -> Wots4TWidgetEntry {
        let dateFilter = NSPredicate(format: "%K >= %d", #keyPath(AllocationMO.dayNumber64), DayNumber.today.value)
        let allocationMOs = CoreData.fetch(from: AllocationMO.tableName,
                                         filter: dateFilter,
                                         limit: 4,
                                         sort: (key: #keyPath(AllocationMO.dayNumber64), direction: .ascending),
                                               (key: #keyPath(AllocationMO.slot16), direction: .ascending),
                                               (key: #keyPath(AllocationMO.allocated), direction: .ascending)
                          ) as! [AllocationMO]
        
        var allocations: [Wots4TWidgetAllocation] = []
        for allocationMO in allocationMOs {
            if allocationMO.dayNumber - DayNumber.today < 7 {
                let mealFilter = NSPredicate(format: "%K = %@", #keyPath(MealMO.mealId), allocationMO.mealId as CVarArg)
                if let mealMO = (CoreData.fetch(from: MealMO.tableName, filter: mealFilter) as! [MealMO]).first {
                    allocations.append(Wots4TWidgetAllocation(dayNumber: allocationMO.dayNumber, mealMO: mealMO))
                }
            }
        }
        return Wots4TWidgetEntry(date: Date(), allocations: allocations)
    }
}

struct Wots4TWidgetAllocation : Identifiable {
    let id = UUID()
    let dayNumber: DayNumber
    let slot = 0
    let mealMO: MealMO
}

struct Wots4TWidgetEntry: TimelineEntry {
    let date: Date
    let allocations: [Wots4TWidgetAllocation]
}

struct Wots4TWidgetEntryView : View {
    var entry: Wots4TWidgetEntry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            Wots4TWidgetSmallView(entry: entry)
        case .systemMedium:
            Wots4TWidgetMediumView(entry: entry)
        case .systemLarge:
            Wots4TWidgetLargeView(entry: entry)
        default:
            EmptyView()
        }
    }
}

struct Wots4TWidgetSmallView : View {
    var entry: Wots4TWidgetEntry

    var body: some View {
        if let allocation = entry.allocations.first {
            let dayNumber = allocation.dayNumber
            let mealMO = allocation.mealMO
            GeometryReader { (geometry) in
                ZStack {
                    VStack {
                        MealView(name: mealMO.name, desc: mealMO.desc, imageData: mealMO.image, urlImageData: mealMO.urlImageCache, imageOnly: true, height: geometry.size.height - 24, imageWidth: geometry.size.width)
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        Text(dayNumber.toNearbyString())
                            .font(.headline)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(Palette.background.themeText)
                        Spacer().frame(height: 2)
                    }
                }
                .background(Palette.background.background)
            }
        } else {
            Wots4TWidgetNoMealsPlanned()
        }
    }
}

struct Wots4TWidgetMediumView : View {
    var entry: Wots4TWidgetEntry

    var body: some View {
        if let allocation = entry.allocations.first {
            let dayNumber = allocation.dayNumber
            let mealMO = allocation.mealMO
            HStack {
                Spacer().frame(width: 16)
                VStack {
                    MealView(title: dayNumber.toNearbyString(), name: mealMO.name, desc: mealMO.desc, imageData: mealMO.image, urlImageData: mealMO.urlImageCache, height: 120, imageWidth: 120)
                }
                .background(Palette.background.background)
                .frame(height: 120)
            }
        } else {
            Wots4TWidgetNoMealsPlanned()
        }
    }
}

struct Wots4TWidgetLargeView : View {
    var entry: Wots4TWidgetEntry

    var body: some View {
        if !entry.allocations.isEmpty {
            VStack {
                Spacer().frame(height: 12)
                ForEach(entry.allocations) { (allocation) in
                    let dayNumber = allocation.dayNumber
                    let mealMO = allocation.mealMO
                    HStack {
                        Spacer().frame(width: 16)
                        VStack {
                            MealView(title: dayNumber.toNearbyString(), name: mealMO.name, imageData: mealMO.image, urlImageData: mealMO.urlImageCache, height: 80, imageWidth: 120)
                        }
                        .background(Palette.background.background)
                        .frame(height: 80)
                    }
                }
                Spacer()
            }
        } else {
            Wots4TWidgetNoMealsPlanned()
        }
    }
}

struct Wots4TWidgetNoMealsPlanned : View {

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("No Meals Planned")
                Spacer()
            }
            Spacer()
        }
        .font(.caption)
        .minimumScaleFactor(0.5)
        .background(Palette.background.background)
    }
}

struct Wots4T_Widget_Extension_Previews: PreviewProvider {
    static var previews: some View {
        Wots4TWidgetEntryView(entry: Wots4TWidgetEntry(date: Date(), allocations: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
