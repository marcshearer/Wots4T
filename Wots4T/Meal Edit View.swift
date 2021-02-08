//
//  Meal Edit View.swift
//  Wots4T
//
//  Created by Marc Shearer on 05/02/2021.
//

import SwiftUI

struct MealEditView: View {
    
    @State var meal: MealViewModel
    
    var body: some View {
        VStack {
            Banner(title: meal.name)
            Spacer()
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
