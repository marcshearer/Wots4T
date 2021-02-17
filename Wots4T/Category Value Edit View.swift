//
//  Category Value Edit View.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct CategoryValueEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var categoryValue: CategoryValueViewModel
    
    @State var confirmDelete = false
    @State var saveError = false
    @State var title: String = ""
    let frequencies = Frequency.allCases
    
    @ObservedObject var data = DataModel.shared

    @State private var frequencyIndex: Int = 0
        
    var body: some View {
        VStack {
            Banner(title: $title,
                   backCheck: {
                        if categoryValue.categoryValueMO == nil && categoryValue.name == "" {
                            return true
                        } else {
                            if self.categoryValue.canSave {
                                self.categoryValue.save()
                            }
                            saveError = !self.categoryValue.canSave
                            return !saveError
                        }
                   },
                   optionMode: .buttons,
                   options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(.red)),
                            action: {
                                if self.categoryValue.categoryValueMO == nil {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    confirmDelete = true
                                }
                            })
                   ])
                    .alert(isPresented: $confirmDelete, content: {
                        self.delete()
                    })

                Input(title: categoryValueNameTitle.capitalized, field: $categoryValue.name, topSpace: 0)
                
                PickerInput(title: categoryValueFrequencyTitle.capitalized, field: $frequencyIndex, values: frequencies.map{$0.string.capitalized})
                    .onChange(of: frequencyIndex, perform: { index in
                        categoryValue.frequency = frequencies[index]
                    })
                Spacer()
                    .alert(isPresented: $saveError, content: {
                        Alert(title: Text("Error!"),
                              message: Text(categoryValue.saveMessage))
                    })
        }
        .onAppear {
            self.frequencyIndex = frequencies.firstIndex(where: {$0 == categoryValue.frequency}) ?? 0
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    private func delete() -> Alert {
        return Alert(title: Text("Warning!"),
              message: Text("Are you sure you want to delete this \(categoryValueName)?"),
              primaryButton:
                .destructive(Text("Delete")) {
                    self.categoryValue.remove()
                    self.presentationMode.wrappedValue.dismiss()
                },
              secondaryButton:
                .cancel())
    }
}

struct CategoryValueEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryValueEditView(categoryValue: CategoryValueViewModel(categoryId: UUID(), name: "Chicken", frequency: .often), title: "New \(categoryValueName)")
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}

