//
//  Category Edit View.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct CategoryEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var category: CategoryViewModel
    
    @State var confirmDelete = false
    @State var saveError = false
    @State var title: String = ""
    
    @ObservedObject var data = DataModel.shared

    @State private var importanceIndex: Int = 0

    let importances = Importance.allCases

    var body: some View {
        VStack {
            Banner(title: $title,
                   backCheck: {
                        if category.categoryMO == nil && category.name == "" {
                            return true
                        } else {
                            if self.category.canSave { self.category.save() }
                            saveError = !self.category.canSave
                            return !saveError
                        }
                   },
                   optionMode: .buttons,
                   options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(.red)),
                            action: {
                                if self.category.categoryMO == nil {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    confirmDelete = true
                                }
                            })
                   ])
                    .alert(isPresented: $confirmDelete, content: {
                        self.delete()
                    })
            VStack {
                Spacer().frame(height: 16)
                Input(title: categoryNameTitle.capitalized, field: $category.name, topSpace: 0)
                PickerInput(title: categoryImportanceTitle.capitalized, field: $importanceIndex, values: importances.map{$0.string.capitalized})
                    .onChange(of: importanceIndex, perform: { index in
                        category.importance = importances[index]
                    })
                
                CategoryValueListView(title: categoryValuesTitle.capitalized , addOption: true, category: category)
                Spacer()
                    .alert(isPresented: $saveError, content: {
                        Alert(title: Text("Error!"),
                              message: Text(category.saveMessage))
                    })
            }
        }

        .onAppear {
            self.importanceIndex = importances.firstIndex(where: {$0 == category.importance}) ?? 0
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    private func delete() -> Alert {
        return Alert(title: Text("Warning!"),
              message: Text("Are you sure you want to delete this \(categoryName)?"),
              primaryButton:
                .destructive(Text("Delete")) {
                    self.category.remove()
                    self.presentationMode.wrappedValue.dismiss()
                },
              secondaryButton:
                .cancel())
    }
}

struct CategoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryEditView(category: CategoryViewModel(name: "Carbs", importance: .highest), title: "New \(categoryName)")
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
