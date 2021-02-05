//
//  Menu List View.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/01/2021.
//

import SwiftUI

struct MealListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String
    
    var body: some View {
        VStack {
            /*
            HStack {
                Spacer().frame(width: 16)
                Text(mealNamePlural.capitalized).font(.largeTitle)
                Spacer()
                Menu {
                    Button {
                        // style = 0
                    } label: {
                        Text("Linear")
                        Image(systemName: "arrow.down.right.circle")
                    }.menuStyle(DefaultMenuStyle())
                    Button {
                        // style = 1
                    } label: {
                        Text("Radial")
                        Image(systemName: "arrow.up.and.down.circle")
                    }
                } label: {
                    Image(systemName: "line.horizontal.3").font(.largeTitle)
                        .foregroundColor(.black)
                }
                Spacer().frame(width: 16)
            }
 */
            VStack {
                Banner(title: title)
                LazyVStack {
                    ForEach(DataModel.shared.meals) { meal in
                        MealSummaryView(meal: meal, imageWidth: 100)
                            .frame(height: 80)
                    }
                    .onDelete(perform: deleteItems)
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
       
    var addButton: some View {
        Button(action: {
            // TODO
        }, label: {
            ZStack(alignment: .trailing) {
                Rectangle() // 3
                    .fill(Color.red.opacity(0.0001)) // 4
                    .frame(width: 40, height: 40)
                Image(systemName: "plus")
            }
        })
    }
    
    private func addItem() {
        withAnimation {
            
        }
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
