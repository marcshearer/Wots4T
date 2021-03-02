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
    @State var linkToEditCategoryValue = CategoryValueViewModel()
    @State var linkToEditTitle: String?

    var body: some View {
        ZStack {
            Palette.background.background
                .ignoresSafeArea()
            VStack(spacing: 0) {
                if let title = title {
                    InputTitle(title: title,
                               buttonImage: AnyView(Image(systemName: "plus.circle.fill").font(.title).foregroundColor(Palette.listButton.background)),
                               buttonAction: !addOption ? nil : {
                                self.linkToEditCategoryValue = CategoryValueViewModel(categoryId: category.categoryId)
                                self.linkToEditTitle = newCategoryValuesName.capitalized
                                self.linkToEdit = true
                               })
                    Spacer().frame(height: 8)
                }
                ScrollView(showsIndicators: MyApp.target == .macOS) {
                LazyVStack {
                    let categoryValues = (DataModel.shared.categoryValues[category.categoryId] ?? [:]).map{$1}.sorted(by: {Utility.lessThan([$1.frequency.rawValue, $1.name], [$0.frequency.rawValue, $0.name], [.int, .string])})
                    ForEach(categoryValues) { categoryValue in
                        VStack {
                            HStack(alignment: .top) {
                                Spacer().frame(width: 38)
                                Text(categoryValue.name)
                                    .font(.body)
                                    .foregroundColor(Palette.background.text)
                                    .lineLimit(1)
                                Spacer()
                            }
                            Spacer().frame(height: 16)
                        }
                        .onTapGesture {
                            self.linkToEditTitle = editCategoryValueName.capitalized
                            self.linkToEditCategoryValue = categoryValue
                            self.linkToEdit = true
                        }
                    }
                }
                }
                Spacer()
            }
            .noNavigationBar
            NavigationLink(destination: CategoryValueEditView(categoryValue: self.linkToEditCategoryValue, title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
        }
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
