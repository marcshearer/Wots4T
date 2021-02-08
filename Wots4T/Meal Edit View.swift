//
//  Meal Edit View.swift
//  Wots4T
//
//  Created by Marc Shearer on 05/02/2021.
//

import SwiftUI

struct MealEditView: View {
    
    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        VStack {
            Banner(title: $meal.name)
            Input(title: nameTitle, field: $meal.name)
            Input(title: descTitle, field: $meal.desc, height: 60)
            Input(title: urlTitle, field: $meal.url, height: 60)
            Input(title: notesTitle, field: $meal.notes, height: 180)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct Input : View {
    
    var title: String?
    @Binding var field: String
    var height: CGFloat = 40
    var onChange: ((String)->())?
    
    var body: some View {

        VStack {
            Spacer().frame(height: 32)
                
            if let title = title {
                HStack {
                    Spacer().frame(width: 16)
                    Text(title).font(.headline)
                    Spacer()
                }
            }

            HStack {
                Spacer().frame(width: 32)
                TextEditor(text: $field)
                    .lineLimit(1)
                    .padding(.all, 1)
                    .background(Color(.lightGray))
                Spacer().frame(width: 16)
            }
            .frame(height: self.height)
        }
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
