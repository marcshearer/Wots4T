//
//  Menu List View.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import SwiftUI

struct MealListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var linkToAdd = false

    var title: String
    var allocateDayNumber: DayNumber?
    var allocateSlot: Int?
    
    var body: some View {
        VStack {
            Banner(title: title,
                   menuImage: AnyView(Image(systemName: "plus.circle.fill").font(.largeTitle).foregroundColor(.blue)),
                   menuAction: { self.linkToAdd = true })
            LazyVStack {
                ForEach(DataModel.shared.meals) { meal in
                    MealSummaryView(meal: meal, imageWidth: 100)
                        .frame(height: 80)
                        .onTapGesture {
                            if allocateDayNumber == nil {
                                
                            } else {
                                self.allocate(meal: meal)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                }
                .onDelete(perform: deleteItems)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    private func allocate(meal: MealViewModel) {
        let allocation = AllocationViewModel(dayNumber: self.allocateDayNumber!, slot: self.allocateSlot!, meal: meal)
        allocation.insert()
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for offset in offsets {
                DataModel.shared.meals[offset].remove()
            }
        }
    }
}

struct MenuListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MealListView(title: chooseName)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
