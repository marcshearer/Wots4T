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
    @State var startAt: Int? = -1
    @State var linkEditMeals = false
    @State var linkEditCategories = false
    @State var linkDisplayMeal: MealViewModel?
    @State var title = appName
    
    @ObservedObject var data = DataModel.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                let today = DayNumber.today
                
                Banner(title: $title, back: false,
                       optionMode: .menu,
                       options: [BannerOption(text: "Setup \(editMealsName)",  action: { self.linkEditMeals = true }),
                                 BannerOption(text: "Setup \(editCategoriesName)", action: { self.linkEditCategories = true })])

                Spacer().frame(height: 10)
                ScrollView {
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
                .navigationBarTitle("")
                .navigationBarHidden(true)
                NavigationLink(destination: MealListView(title: editMealsName), isActive: $linkEditMeals) { EmptyView() }
                NavigationLink(destination: CategoryListView(title: editCategoriesName), isActive: $linkEditCategories) { EmptyView() }
            }
            .onAppear {
                Utility.mainThread {
                    self.startAt = 0
                }
            }
        }
    }
    
    func date(offset: Int) -> String {
        return (DayNumber.today + offset).date.toString(format: dateFormat, localized: false)
    }
}

fileprivate struct CalendarView_Entry: View {
    var today: DayNumber
    var offset: Int
    @ObservedObject var data = DataModel.shared

    var body: some View {
        if let meal = data.allocations[today + offset]?[0]?.meal {
            NavigationLink(destination: MealDisplayView(meal: meal)) {
                CalendarView_EntryContent(today: today, offset: offset)
            }
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
    @ObservedObject var data = DataModel.shared
    
    var body: some View {
        let allocation = data.allocations[today + offset]?[0] // Assume slot is zero for now
        if allocation != nil || offset >= 0 {
            VStack {
                Divider().padding(.leading, 24).padding(.trailing, 12)
                Spacer().frame(height: 8)
                CalendarView_AllocationTitle(dayNumber: today + offset, highlight: offset == 0, delete: allocation != nil)
                if let allocation = allocation {
                    MealSummaryView(meal: allocation.meal)
                } else {
                    CalendarView_AllocationPlaceholder()
                }
                Spacer()
                
            }
            .frame(height: 110)
        }
    }
}

fileprivate struct CalendarView_AllocationTitle: View {
    fileprivate var dayNumber: DayNumber
    fileprivate var highlight: Bool
    fileprivate var delete: Bool

    @ObservedObject var data = DataModel.shared

    var body: some View {
        HStack {
            Spacer().frame(width: 32)
            Text(dayNumber.date.toString(format: dateFormat))
                .font(.headline)
                .foregroundColor(self.highlight ? .red : .blue)
            Spacer()
            if delete {
                Button(action: { self.removeAllocation(dayNumber: dayNumber, slot: 0) }) {
                    Image(systemName: "multiply.circle.fill").font(.headline).foregroundColor(.gray)
                }
                Spacer().frame(width: 16)
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
                .foregroundColor(.gray)
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
            DataModel.shared.load()
        }
    }
}
