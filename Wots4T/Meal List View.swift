//
//  Menu List View.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import SwiftUI

struct MealListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var title: String
    var allocateDayNumber: DayNumber?
    var allocateSlot: Int?
    
    @ObservedObject var data = DataModel.shared

    @State private var startAt: UUID?
    @State var linkToEdit = false
    @State var linkToEditMeal: MealViewModel?
    @State var linkToEditTitle: String?
    @State var meals: [MealViewModel] = []
    @State private var displayedRemoteChanges: Int = 0
    
    let categories = DataModel.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance, $0.name], [$1.importance, $1.name], [.int, .string])})
    @State private var categoryValues: [UUID: CategoryValueViewModel] = [:]

    var body: some View {
        let meals = DataModel.shared.sortedMeals(dayNumber: allocateDayNumber).filter({self.filter($0)})
        ZStack {
            Palette.background.background
                .ignoresSafeArea()
            VStack {
                MealListView_Banner(title: title, editMode: allocateDayNumber == nil)
                ScrollView(showsIndicators: false) {
                    Spacer().frame(height: 8)
                    MealListView_FilterInput(categoryValues: $categoryValues)
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack {
                            ForEach(meals) { meal in
                                MealSummaryView(meal: meal, imageWidth: 100, showInfo: allocateDayNumber != nil)
                                    .id(meal.mealId)
                                    .frame(height: 80)
                                    .onTapGesture {
                                        if allocateDayNumber == nil {
                                            self.linkToEdit = true
                                            self.linkToEditTitle = mealName.capitalized
                                            self.linkToEditMeal = meal
                                        } else {
                                            self.allocate(meal: meal)
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                            }
                        }
                        .onChange(of: self.startAt) { (startAt) in
                            if let startAt = startAt {
                                scrollViewProxy.scrollTo(startAt, anchor: .top)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .onChange(of: DataModel.shared.publishedRemoteUpdates, perform: { value in
                // Remote data model has changed - refresh it
                if value > self.displayedRemoteChanges {
                    self.displayedRemoteChanges = DataModel.shared.load()
                }
            })
            .onSwipe(.right) {
                presentationMode.wrappedValue.dismiss()
            }
            .onAppear {
                Utility.mainThread {
                    if let meal = meals.first {
                        self.startAt = meal.mealId
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .navigationBarHidden(true)
            NavigationLink(destination: MealEditView(meal: self.linkToEditMeal ?? MealViewModel(), title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
        }
    }
    
    private func index(of meal: MealViewModel, in meals: [MealViewModel]) -> Int {
        return meals.firstIndex(where: {$0.mealId == meal.mealId}) ?? -1
    }
    
    private func allocate(meal: MealViewModel) {
        let allocation = AllocationViewModel(dayNumber: self.allocateDayNumber!, slot: self.allocateSlot!, meal: meal, allocated: Date())
        allocation.insert()
    }
    
    private func filter(_ meal: MealViewModel) -> Bool {
        var include = true
        for category in categories {
            if let filterValue = categoryValues[category.categoryId]?.valueId {
                if filterValue != meal.categoryValues[category.categoryId]?.valueId {
                    include = false
                    break
                }
            }
        }
        return include
    }
}

struct MealListView_Banner: View {

    @State var title: String
    @State var editMode: Bool

    @State var linkToEdit = false

    var body: some View {
        Banner(title: $title,
               optionMode: (editMode ? .buttons : .none),
               options: [
                BannerOption(
                    image: AnyView(Image(systemName: "plus.circle.fill").font(.largeTitle).foregroundColor(.blue)),
                    action: {
                        self.linkToEdit = true
                    })])
        NavigationLink(destination: MealEditView(meal: MealViewModel(), title: "New \(mealName.capitalized)"), isActive: $linkToEdit) { EmptyView() }
    }
}

struct MealListView_FilterInput: View {

    @Binding var categoryValues: [UUID: CategoryValueViewModel]
    
    private let height: CGFloat = 32
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            ZStack {
                Palette.filter.background
                    .ignoresSafeArea()
                    .cornerRadius(10)
                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    HStack {
                        Spacer().frame(width: 8)
                        Text("FILTER BY:").font(.caption2)
                        Spacer()
                    }
                    Spacer().frame(height: 8)
                    HStack {
                        Spacer().frame(width: 16)
                        GeometryReader { geometry in
                            let width: CGFloat = (geometry.size.width - 16) / 3
                            ScrollView(.horizontal, showsIndicators: false) {
                                let categories = self.getCategories()
                                HStack {
                                    ForEach(categories) { category in
                                        let categoryId = category.categoryId
                                        let value = categoryValues[categoryId]
                                        let title = value?.name ?? category.name.uppercased()
                                        let values = self.getCategoryValues(categoryId: categoryId)
                                        let names = ["No \(category.name.lowercased()) filter"] + values.map{$0.name}
                                        
                                        Menu(title) {
                                            ForEach(0..<(names.count)) { (index) in
                                                Button(action: {
                                                    categoryValues[categoryId] = (index == 0 ? nil : values[index - 1])
                                                }) {
                                                    Text(names[index]).foregroundColor(index == 0 ? Palette.menuEntry.text : Palette.menuEntry.strongText)
                                                }
                                            }
                                        }
                                        .foregroundColor(value == nil ? Palette.disabledButton.faintText : Palette.enabledButton.text)
                                        .font(value == nil ? .caption : .callout)
                                        .frame(width: width, height: height)
                                        .background(value == nil ? Palette.disabledButton.background : .blue)
                                        .cornerRadius(height/2)
                                    }
                                }
                            }
                        }
                        Spacer().frame(width: 8)
                    }
                    Spacer().frame(height: 16)
                }
                .frame(height: 80)
            }
            Spacer().frame(width: 8)
        }
    }
    
    func getCategories() -> [CategoryViewModel] {
        return DataModel.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance, $0.name], [$1.importance, $1.name], [.int, .string])})
    }
    
    func getCategoryValues(categoryId: UUID) -> [CategoryValueViewModel] {
        return (DataModel.shared.categoryValues[categoryId] ?? [:]).map{$1}.sorted(by: {!Utility.lessThan([$0.frequency, $0.name], [$1.frequency, $1.name], [.int, .string])})
    }
}

struct MealListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MealListView(title: chooseName)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
