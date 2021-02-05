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
    @State var initial = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                let today = DayNumber.today
                
                Banner(title: appName, back: false)

                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(-14...28, id: \.self) { offset in
                                CalendarView_Entry(today: today, offset: offset)
                                    .id(today + offset)
                            }
                            Spacer()
                        }
                        .onChange(of: self.initial) { (initial) in
                            if initial {
                                scrollViewProxy.scrollTo(today, anchor: .top)
                                self.initial = false
                            }
                        }
                    }.onAppear {
                        self.initial = true
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
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
    
    var body: some View {
        NavigationLink(destination: MealListView(title: chooseName)) {
            let allocation = DataModel.shared.allocations.first(where: {$0.dayNumber == today + offset && $0.slot == 0})
            if true || allocation != nil || offset >= 0 {
                VStack {
                    Divider().padding(.leading, 24).padding(.trailing, 12)
                    Spacer().frame(height: 8)
                    CalendarView_AllocationTitle(dayNumber: today + offset, highlight: offset == 0)
                    if let allocation = allocation {
                        MealSummaryView(meal: allocation.meal)
                    } else {
                        CalendarView_AllocationPlaceholder()
                    }
                    Spacer()
                    
                }
                .frame(height: 100)
            }
        }

    }
}

fileprivate struct CalendarView_AllocationTitle: View {
    fileprivate var dayNumber: DayNumber
    fileprivate var highlight: Bool
    
    var body: some View {
        HStack {
            Spacer().frame(width: 32)
            Text(dayNumber.date.toString(format: "EEEE d MMMM"))
                .font(.headline)
                .foregroundColor(self.highlight ? .red : .blue)
            Spacer()
        }
    }
}

fileprivate struct CalendarView_AllocationPlaceholder: View {
    
    var body: some View {
        Spacer()
            .frame(height: 16)
        HStack {
            Spacer().frame(width: 64)
            Text("Choose a meal...")
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

struct Banner: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String
    var back: Bool = true
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer().frame(width: 16)
                if back {
                    backButton
                }
                Text(title).font(.largeTitle).bold()
                Spacer()
            }
            Spacer().frame(height: 16)
        }
        .frame(height: 80)
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.left").font(.largeTitle)
            }
        })
    }
}
