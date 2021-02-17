//
//  Category Value List View.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct CategoryValueListView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var title: String?
    @State var addOption = false
    
    @State var category: CategoryViewModel
    
    @ObservedObject var data = DataModel.shared

    @State var linkToEdit = false
    @State var linkToEditCategoryValue: CategoryValueViewModel?
    @State var linkToEditTitle: String?

    var body: some View {
        VStack {
            if let title = title {
                InputTitle(title: title,
                           buttonImage: AnyView(Image(systemName: "plus.circle.fill").font(.title).foregroundColor(.gray)),
                           buttonAction: !addOption ? nil : {
                                self.linkToEdit = true
                                self.linkToEditTitle = "New \(categoryValueName.capitalized)"
                                self.linkToEditCategoryValue = nil
                           })
                Spacer().frame(height: 8)
            }
            LazyVStack {
                let categoryValues = (DataModel.shared.categoryValues[category.categoryId] ?? [:]).map{$1}.sorted(by: {$0.frequency > $1.frequency})
                ForEach(categoryValues) { categoryValue in
                    VStack {
                        HStack(alignment: .top) {
                            Spacer().frame(width: 38)
                            Text(categoryValue.name)
                                .font(.body)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            Spacer()
                        }
                        Spacer().frame(height: 16)
                    }
                    .onTapGesture {
                        self.linkToEditTitle = categoryValueName.capitalized
                        self.linkToEditCategoryValue = categoryValue
                        self.linkToEdit = true
                    }
                }
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        NavigationLink(destination: CategoryValueEditView(categoryValue: self.linkToEditCategoryValue ?? CategoryValueViewModel(categoryId: category.categoryId), title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
    }
}

struct CategoryValueListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            CategoryValueListView(category: DataModel.shared.categories.first!.value)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
