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
    @State var linkToEditCategory = CategoryViewModel()
    @State var linkToEditTitle: String?

    @State var title: String = ""
    
    @ObservedObject var data = MasterData.shared

    var body: some View {
        StandardView {
            VStack {
                Banner(title: $title,
                       backAction: exit,
                       optionMode: .buttons,
                       options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "plus.circle.fill").font(.largeTitle).foregroundColor(Palette.bannerButton.background)),
                            action: {
                                self.linkToAdd = true
                                self.linkToEdit = true
                                self.linkToEditTitle = "New \(categoryName.capitalized)"
                                self.linkToEditCategory = CategoryViewModel()
                            })])
                ScrollView(showsIndicators: MyApp.target == .macOS) {
                    LazyVStack {
                        let categories = MasterData.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance.rawValue, $0.name], [$1.importance.rawValue, $1.name], [.int, .string])})
                        ForEach(categories) { category in
                            VStack {
                                HStack(alignment: .top) {
                                    Spacer().frame(width: 48)
                                    Text(category.name)
                                        .font(.title)
                                        .foregroundColor(Palette.background.text)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                Spacer().frame(height: 4)
                                HStack(alignment: .top) {
                                    Spacer().frame(width: 64)
                                    let categoryValues =  MasterData.shared.categoryValues[category.categoryId] ?? [:]
                                    if categoryValues.isEmpty {
                                        Text("No values for \(categoryName)")
                                            .font(.caption)
                                            .foregroundColor(Palette.background.faintText)
                                    } else {
                                        let valueString = Utility.toString( categoryValues.map{$1}.sorted(by: {Utility.lessThan([$1.frequency.rawValue, $1.name], [$0.frequency.rawValue, $0.name], [.int, .string])}).map{$0.name})
                                        Text(valueString)
                                            .font(.caption)
                                            .foregroundColor(Palette.background.contrastText)
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
                }
                Spacer()
            }
            NavigationLink(destination: CategoryEditView(category: self.linkToEditCategory, title: self.linkToEditTitle ?? ""), isActive: $linkToEdit) { EmptyView() }
        }
        .onAppear() {
            MasterData.shared.suspendRemoteUpdates(true)
        }
        .onSwipe(.right) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func exit() {
        MasterData.shared.suspendRemoteUpdates(false)
    }
}

struct CategoryListView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            CategoryListView(title: editCategoriesName)
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            MasterData.shared.load()
        }
    }
}
