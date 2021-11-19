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
    
    @ObservedObject var data = MasterData.shared

    @State private var startAt: UUID?
    @State var linkToEdit = false
    @State var linkToEditMeal: MealViewModel?
    @State var linkToEditTitle: String?
    @State var meals: [MealViewModel] = []
    @State private var displayedRemoteChanges: Int = 0
    
    let categories = MasterData.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance.rawValue, $0.name], [$1.importance.rawValue, $1.name], [.int, .string])})
    @State private var categoryValues: [UUID: CategoryValueViewModel] = [:]
    @State private var searchText: String = ""

    var body: some View {
        let meals = MasterData.shared.sortedMeals(dayNumber: allocateDayNumber).filter({self.filter($0)})
        StandardView {
            VStack {
                MealListView_Banner(title: title, editMode: allocateDayNumber == nil)
                ScrollView(showsIndicators: MyApp.target == .macOS) {
                    Spacer().frame(height: 8)
                    MealListView_FilterInput(categoryValues: $categoryValues, searchText: $searchText)
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
            .onChange(of: MasterData.shared.publishedRemoteUpdates, perform: { value in
                // Remote data model has changed - refresh it
                if value > self.displayedRemoteChanges {
                    self.displayedRemoteChanges = MasterData.shared.load()
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
            NavigationLink(destination: MealEditView(meal: self.linkToEditMeal ?? MealViewModel(), title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
        }
    }
    
    private func index(of meal: MealViewModel, in meals: [MealViewModel]) -> Int {
        return meals.firstIndex(where: {$0.mealId == meal.mealId}) ?? -1
    }
    
    private func allocate(meal: MealViewModel) {
        let allocation = AllocationViewModel(dayNumber: self.allocateDayNumber!, slot: self.allocateSlot!, meal: meal, allocated: Date.today)
        allocation.insert()
    }
    
    private func filter(_ meal: MealViewModel) -> Bool {
        var include = true
        if searchText != "" {
            include = self.wordSearch(for: searchText, in: meal.name + " " + meal.desc)
        }
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
    
    private func wordSearch(for searchWords: String, in target: String) -> Bool {
        var result = true
        let searchList = searchWords.uppercased().components(separatedBy: " ")
        let targetList = target.uppercased().components(separatedBy: " ")
        
        for searchWord in searchList {
            var found = false
            for targetWord in targetList {
                if targetWord.starts(with: searchWord) {
                    found = true
                }
            }
            if !found {
                result = false
            }
        }
        
        return result
        
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
    @Binding var searchText: String
    
    private let height: CGFloat = 32
    
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            ZStack {
                Palette.filter.background
                    .ignoresSafeArea(edges: .all)
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
                                MealListView_FilterInput_Categories(width: width, height: height, categoryValues: $categoryValues)
                            }
                        }
                        Spacer().frame(width: 8)
                    }
                    Spacer().frame(height: 8)
                    HStack {
                        Spacer().frame(width: 16)
                        ZStack {
                            Rectangle()
                                .foregroundColor(Palette.input.background)
                                .cornerRadius(20)
                            if searchText.isEmpty {
                                HStack {
                                    Spacer().frame(width: 20)
                                    Text("Search words")
                                        .foregroundColor(Palette.input.faintText)
                                    Spacer()
                                }
                            }
                            HStack {
                                Spacer().frame(width: 16)
                                TextEditor(text: $searchText)
                                    .foregroundColor(Palette.input.text)
                                Spacer().frame(width: 16)
                            }
                        }
                        Spacer().frame(width: 8)
                    }
                    Spacer().frame(height: 16)
                }
                .frame(height: 136)
            }
            Spacer().rightSpacer
        }
    }
}

struct MealListView_FilterInput_Categories: View {
    var width: CGFloat
    var height: CGFloat
    @Binding var categoryValues: [UUID: CategoryValueViewModel]
    
    var body: some View {
        let categories = self.getCategories()
        HStack {
            ForEach(categories) { category in
                if let categoryId = category.categoryId {
                    let value = categoryValues[categoryId]
                    let title = value?.name ?? category.name.uppercased()
                    let values = self.getCategoryValues(categoryId: categoryId)
                    let names = ["No \(category.name.lowercased()) filter"] + values.map{$0.name}
                    
                    Menu {
                        ForEach(0..<(names.count)) { (index) in
                            Button(action: {
                                categoryValues[categoryId] = (index == 0 ? nil : values[index - 1])
                            }) {
                                Text(names[index]).foregroundColor(index == 0 ? Palette.menuEntry.text : Palette.menuEntry.strongText)
                            }
                        }
                    } label: {
                        Label {
                            Text(title).frame(width: width)
                        } icon: {
                            
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
        
    func getCategories() -> [CategoryViewModel] {
        return MasterData.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance.rawValue, $0.name], [$1.importance.rawValue, $1.name], [.int, .string])})
    }
    
    func getCategoryValues(categoryId: UUID) -> [CategoryValueViewModel] {
        return (MasterData.shared.categoryValues[categoryId] ?? [:]).map{$1}.sorted(by: {Utility.lessThan([$1.frequency.rawValue, $1.name], [$0.frequency.rawValue, $0.name], [.int, .string])})
    }

}

struct MealListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MealListView(title: chooseName)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            MasterData.shared.load()
        }
    }
}
