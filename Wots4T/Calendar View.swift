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
    
    @ObservedObject var data = DataModel.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                let today = DayNumber.today
                
                Banner(title: appName, back: false, menuOptions: [(text: "Edit Meals", action: { self.linkEditMeals = true })])

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
                NavigationLink(destination: MealListView(title: "Edit Meals"), isActive: $linkEditMeals) { EmptyView() }
            }
            .onAppear {
                Utility.mainThread {
                    self.startAt = 0
                }
            }
        }
    }
    
    func date(offset: Int) -> String {
        return (DayNumber.today + offset).date.toString(format: "EEEE d MMMM", localized: false)
    }
}

fileprivate struct CalendarView_Entry: View {
    var today: DayNumber
    var offset: Int
    @ObservedObject var data = DataModel.shared

    var body: some View {
        NavigationLink(destination: MealListView(title: chooseName, allocateDayNumber: today + offset, allocateSlot: 0)) {
            let allocation = data.allocations.first(where: {$0.dayNumber == today + offset && $0.slot == 0})
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
}

fileprivate struct CalendarView_AllocationTitle: View {
    fileprivate var dayNumber: DayNumber
    fileprivate var highlight: Bool
    fileprivate var delete: Bool

    @ObservedObject var data = DataModel.shared

    var body: some View {
        HStack {
            Spacer().frame(width: 32)
            Text(dayNumber.date.toString(format: "EEEE d MMMM"))
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
        
        if let allocation = data.allocations.first(where: {$0.dayNumber == dayNumber && $0.slot == slot}) {
            allocation.remove()
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
