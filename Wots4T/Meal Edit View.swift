//
//  Meal Edit View.swift
//  Wots4T
//
//  Created by Marc Shearer on 05/02/2021.
//

import SwiftUI

struct MealEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var meal: MealViewModel
    @State var confirmDelete = false
    @State var saveError = false
    
    var body: some View {
        VStack {
            Banner(title: $meal.name,
                   backCheck: {
                        if meal.canSave { self.meal.save() }
                        saveError = !meal.canSave
                        return !saveError
                   },
                   optionMode: .buttons,
                   options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(.red)),
                            action: {
                                if self.meal.mealMO == nil {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    confirmDelete = true
                                }
                            })
                   ])
                    .alert(isPresented: $confirmDelete, content: {
                        self.delete()
                    })

            ScrollView {
                Input(title: nameTitle.capitalized, field: $meal.name, topSpace: 0)
                Input(title: descTitle.capitalized, field: $meal.desc, height: 60)
                AddImage(title: imageTitle.capitalized, image: $meal.image)
                Input(title: urlTitle.capitalized, field: $meal.url, height: 60)
                Input(title: notesTitle.capitalized, field: $meal.notes, height: 180)
                Spacer()
            }
            .alert(isPresented: $saveError, content: {
                Alert(title: Text("Error!"),
                      message: Text(meal.saveMessage))
            })

        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    private func delete() -> Alert {
        return Alert(title: Text("Warning!"),
              message: Text("Are you sure you want to delete this \(mealName)?"),
              primaryButton:
                .destructive(Text("Delete")) {
                    self.meal.remove()
                    self.presentationMode.wrappedValue.dismiss()
                },
              secondaryButton:
                .cancel())
    }
}

struct MealEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealEditView(meal: MealViewModel(name: "Macaroni Cheese", desc: "James Martin's ultimate macaroni cheese", url: "https://www.bbc.co.uk/food/recipes/james_martins_ultimate_60657", notes: ""))
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
