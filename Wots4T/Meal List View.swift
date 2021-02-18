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

    @State var linkToEdit = false
    @State var linkToEditMeal: MealViewModel?
    @State var linkToEditTitle: String?

    var body: some View {
        VStack {
            Banner(title: $title,
                   optionMode: (allocateDayNumber == nil ? .buttons : .none),
                   options: [
                    BannerOption(
                        image: AnyView(Image(systemName: "plus.circle.fill").font(.largeTitle).foregroundColor(.blue)),
                        action: {
                            self.linkToEdit = true
                            self.linkToEditTitle = "New \(mealName.capitalized)"
                            self.linkToEditMeal = nil
                        })])
            ScrollView {
                LazyVStack {
                    let meals = DataModel.shared.sortedMeals(dayNumber: allocateDayNumber)
                    ForEach(meals) { meal in
                        MealSummaryView(meal: meal, imageWidth: 100, showInfo: allocateDayNumber != nil)
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
                Spacer()
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
