//
//  Calendar View.swift
//  Wots4T
//
//  Created by Marc Shearer on 01/02/2021.
//

import Foundation

import SwiftUI
import LinkPresentation

struct CalendarView: View {
    @State private var startAt: Int? = -1
    @State var linkEditMeals = false
    @State var linkEditCategories = false
    @State var linkAbout = false
    @State private var linkDisplayMeal: MealViewModel?
    @State var title = appName
    @State private var displayedRemoteChanges: Int = 0
    
    @ObservedObject var data = MasterData.shared
    @ObservedObject var messageBox = MessageBox.shared

    var body: some View {
        StandardView(navigation: true) {
            VStack(spacing: 0) {
                let today = DayNumber.today
                
                Banner(title: $title, back: false,
                       optionMode: .menu,
                       options: [BannerOption(text: "Setup \(editMealsName)",  action: { self.linkEditMeals = true }),
                                 BannerOption(text: "Setup \(editCategoriesName)", action: { self.linkEditCategories = true }),
                                 BannerOption(text: "About \(appName)", action: { messageBox.show("A \(mealName.capitalized) scheduling app from\nShearer Online Ltd") })])
                
                Spacer().frame(height: 10)
                ScrollView(showsIndicators: MyApp.target == .macOS) {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(-14...28, id: \.self) { offset in
                                CalendarView_Entry(today: today, offset: offset)
                                    .id(offset)
                            }
                            Spacer()
                        }
                        .onChange(of: self.startAt) { (startAt) in
                            if let startAt = startAt {
                                scrollViewProxy.scrollTo(startAt, anchor: .top)
                            }
                        }
                    }
                }
            }
            .onChange(of: MasterData.shared.publishedRemoteUpdates, perform: { value in
                // Remote data model has changed - refresh it
                if value > self.displayedRemoteChanges {
                    self.displayedRemoteChanges = MasterData.shared.load()
                }
            })
            .onAppear {
                Utility.mainThread {
                    Version.current.check(upgrade: true)
                    self.startAt = 0
                }
            }
            NavigationLink(destination: MealListView(title: editMealsName), isActive: $linkEditMeals) { EmptyView() }
            NavigationLink(destination: CategoryListView(title: editCategoriesName), isActive: $linkEditCategories) { EmptyView() }
            NavigationLink(destination: MessageBoxView(), isActive: $linkAbout) { EmptyView() }
        }
    }
    
    func date(offset: Int) -> String {
        return (DayNumber.today + offset).date.toString(format: dateFormat, localized: false)
    }
}

fileprivate struct CalendarView_Entry: View {
    var today: DayNumber
    var offset: Int
    @ObservedObject var data = MasterData.shared
     
    init(today: DayNumber, offset: Int) {
        self.today = today
        self.offset = offset
    }
    
    var body: some View {
        if let allocation = data.allocations[today + offset]?[0] , let meal = allocation.meal {
            NavigationLink(destination: MealDisplayView(meal: meal)) {
                CalendarView_EntryContent(today: today, offset: offset)
            }
            .onDrag({allocation.itemProvider})
        } else {
            NavigationLink(destination: MealListView(title: chooseName, allocateDayNumber: today + offset, allocateSlot: 0)) {
                CalendarView_EntryContent(today: today, offset: offset)
            }
        }
    }
}

fileprivate struct CalendarView_EntryContent: View {
    var today: DayNumber
    var offset: Int
    @ObservedObject var data = MasterData.shared
    let identifier = AllocationItemProvider.readableTypeIdentifiersForItemProvider
    
    var body: some View {
        let allocation = data.allocations[today + offset]?[0] // Assume slot is zero for now
        if allocation != nil || offset >= 0 {
            VStack(spacing: 0) {
                Separator()
                Spacer().frame(height: 8)
                CalendarView_AllocationTitle(dayNumber: today + offset, highlight: offset == 0, delete: allocation != nil)
                if let allocation = allocation {
                    MealSummaryView(meal: allocation.meal)
                } else {
                    CalendarView_AllocationPlaceholder()
                }
                Spacer()
                
            }
            .background(Rectangle().fill(Palette.background.background))
            .frame(height: 110)
            .onDrop(of: identifier, delegate: AllocationDropDelegate(on: today + offset, 0, action: onDrop))
        }
    }
    
    func onDrop(on dayNumber: DayNumber, _ slot: Int, sourceAllocation: AllocationViewModel) {
        if let destAllocation = MasterData.shared.allocations[dayNumber]?[slot] {
            // Swap meals
            let destMeal = destAllocation.meal!
            destAllocation.change(meal: sourceAllocation.meal)
            sourceAllocation.change(meal: destMeal)
            destAllocation.save()
            sourceAllocation.save()
        } else {
            // Change date
            sourceAllocation.change(dayNumber: dayNumber, slot: slot)
            sourceAllocation.save()
        }
    }
}

fileprivate struct CalendarView_AllocationTitle: View {
    fileprivate var dayNumber: DayNumber
    fileprivate var highlight: Bool
    fileprivate var delete: Bool

    @ObservedObject var data = MasterData.shared

    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            Text(dayNumber.toNearbyString())
                .font(.headline)
                .foregroundColor(self.highlight ? Palette.background.strongText : Palette.background.themeText)
            Spacer()
            if delete {
                Button(action: { self.removeAllocation(dayNumber: dayNumber, slot: 0) }) {
                    Image(systemName: "multiply.circle.fill").font(.headline).foregroundColor(Palette.listButton.background)
                }
                Spacer().rightSpacer
            }
        }
    }
    
    private func removeAllocation(dayNumber: DayNumber, slot: Int) {
        if let allocation = data.allocations[dayNumber]?[slot] {
            data.remove(allocation: allocation)
        }
    }
    
}

fileprivate struct CalendarView_AllocationPlaceholder: View {
    
    var body: some View {
        Spacer()
            .frame(height: 16)
        HStack {
            Spacer().frame(width: 64)
            Text(chooseName + "...")
                .foregroundColor(Palette.background.faintText)
                .font(.headline)
            Spacer()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            CalendarView()
        }
        .onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            MasterData.shared.load()
        }
    }
}

