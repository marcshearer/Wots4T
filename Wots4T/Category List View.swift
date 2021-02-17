//
//  Category List View.swift
//  Wots4T
//
//  Created by Marc Shearer on 12/02/2021.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var linkToAdd = false
    @State var linkToEdit = false
    @State var linkToEditCategory: CategoryViewModel?
    @State var linkToEditTitle: String?

    @State var title: String
    
    @ObservedObject var data = DataModel.shared

    var body: some View {
        VStack {
            Banner(title: $title,
                   optionMode: .buttons,
                   options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "plus.circle.fill").font(.largeTitle).foregroundColor(.blue)),
                            action: {
                                self.linkToAdd = true
                                self.linkToEdit = true
                                self.linkToEditTitle = "New \(categoryName.capitalized)"
                                self.linkToEditCategory = nil
                            })])
            LazyVStack {
                let categories = DataModel.shared.categories.map{$1}.sorted(by: {$0.importance < $1.importance})
                ForEach(categories) { category in
                    VStack {
                        HStack(alignment: .top) {
                            Spacer().frame(width: 48)
                            Text(category.name)
                                .font(.title)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            Spacer()
                        }
                        Spacer().frame(height: 4)
                        HStack(alignment: .top) {
                            Spacer().frame(width: 64)
                            let categoryValues =  DataModel.shared.categoryValues[category.categoryId] ?? [:]
                            if categoryValues.isEmpty {
                                Text("No values for \(categoryName)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            } else {
                                let valueString = Utility.toString( categoryValues.map{$1}.sorted(by: {$0.frequency > $1.frequency}).map{$0.name})
                                Text(valueString)
                                .font(.caption2)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            }
                        Spacer()
                        }
                        Spacer().frame(height: 16)
                    }
                    .onTapGesture {
                        self.linkToAdd = false
                        self.linkToEditTitle = categoryName.capitalized
                        self.linkToEditCategory = category
                        self.linkToEdit = true
                    }
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        NavigationLink(destination: CategoryEditView(category: self.linkToEditCategory ?? CategoryViewModel(), title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
    }
}

struct CategoryListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            CategoryListView(title: editCategoriesName)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}