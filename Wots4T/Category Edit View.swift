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
        StandardView {
            VStack {
                Banner(title: $title,
                       backCheck: backCheck,
                       backAction: save,
                       optionMode: .buttons,
                       options: [
                            BannerOption(
                                image: AnyView(Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(Palette.destructiveButton.background)),
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
                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    Input(title: categoryNameTitle.capitalized, field: $category.name, message: $category.nameMessage, topSpace: 0)
                    PickerInput(title: categoryImportanceTitle.capitalized, field: $importanceIndex, values: importances.map{$0.string.capitalized})
                        .onChange(of: importanceIndex, perform: { index in
                            category.importance = importances[index]
                        })
                    CategoryValueListView(title: categoryValuesTitle.capitalized , addOption: true, category: category)
                        // Spacer()
                        .alert(isPresented: $saveError, content: {
                            Alert(title: Text("Error!"),
                                  message: Text(category.saveMessage))
                        })
                }
            }
            .onSwipe(.right) {
                if backCheck() {
                    save()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onAppear {
                self.importanceIndex = importances.firstIndex(where: {$0 == category.importance}) ?? 0
            }
        }
    }
    
    private func backCheck() -> Bool {
        if category.categoryMO == nil && category.name == "" {
            return true
        } else {
            saveError = !self.category.canSave
            return !saveError
        }
    }
    private func save() {
        if self.category.canSave {
            self.category.save()
        }
    }
    
    private func delete() -> Alert {
        return Alert(title: Text("Warning!"),
              message: Text("Are you sure you want to delete this \(categoryName)?\n\nAll values for this category will be deleted and any values for this category which you have setup on meals will be removed."),
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

