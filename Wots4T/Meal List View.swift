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

    @State private var startAt: Int? = -1
    @State var linkToEdit = false
    @State var linkToEditMeal: MealViewModel?
    @State var linkToEditTitle: String?

    @State var categoryValues: [UUID: CategoryValueViewModel] = [:]

    var body: some View {
        ZStack {
            Palette.background.background
                .ignoresSafeArea()
            VStack {
                MealListView_Banner(title: title, editMode: allocateDayNumber == nil)
                ScrollView(showsIndicators: false) {
                    Spacer().frame(height: 8)
                    MealListView_FilterInput(categoryValues: categoryValues)
                    ScrollViewReader { scrollViewProxy in
                        LazyVStack {
                            let meals = DataModel.shared.sortedMeals(dayNumber: allocateDayNumber)
                            ForEach(0..<meals.count) { index in
                                let meal = meals[index]
                                MealSummaryView(meal: meal, imageWidth: 100, showInfo: allocateDayNumber != nil)
                                    .id(index)
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
            .onAppear {
                Utility.mainThread {
                    self.startAt = 0
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .navigationBarHidden(true)
            NavigationLink(destination: MealEditView(meal: self.linkToEditMeal ?? MealViewModel(), title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
        }
    }
    
    private func allocate(meal: MealViewModel) {
        let allocation = AllocationViewModel(dayNumber: self.allocateDayNumber!, slot: self.allocateSlot!, meal: meal)
        allocation.insert()
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

    @State var categoryValues: [UUID: CategoryValueViewModel]
    
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
                                        let title = value?.name ?? category.name!.uppercased()
                                        let values = self.getCategoryValues(categoryId: categoryId)
                                        let names = values.map{$0.name} + ["Not specified"]
                                        
                                        Menu(title) {
                                            ForEach(0..<(names.count)) { (index) in
                                                Button(names[index]) {
                                                    categoryValues[categoryId] = (index == names.count - 1 ? nil : values[index])
                                                }
                                            }
                                        }
                                        .foregroundColor(value == nil ? Palette.disabledButton.faintText : Palette.enabledButton.text)
                                        .font(value == nil ? .caption : .callout)
                                        .frame(width: width, height: height)
                                        .background(value == nil ? Palette.disabledButton.background : Palette.enabledButton.background)
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
        return DataModel.shared.categories.map{$1}.sorted(by: {$0.importance < $1.importance})
    }
    
    func getCategoryValues(categoryId: UUID) -> [CategoryValueViewModel] {
        return (DataModel.shared.categoryValues[categoryId] ?? [:]).map{$1}.sorted(by: {$0.frequency > $1.frequency})
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
