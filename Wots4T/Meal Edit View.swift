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
    @State var linkToAttachments = false
    @State var saveError = false
    @State var title: String
     
    var body: some View {
        StandardView {
            VStack {
                Banner(title: $title,
                       backCheck: self.save,
                       optionMode: .buttons,
                       options: [
                        BannerOption(
                            image: AnyView(Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(Palette.destructiveButton.background)),
                            action: {
                                if self.meal.mealMO == nil {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    confirmDelete = true
                                }
                            }),
                        BannerOption(
                            image: AnyView(Image(systemName: "paperclip.circle.fill").font(.largeTitle).foregroundColor(Palette.bannerButton.background)),
                            action: {
                                self.linkToAttachments = true
                            })
                       ])
                    .alert(isPresented: $confirmDelete, content: {
                        self.delete()
                    })
                
                ScrollView(showsIndicators: (MyApp.target == .macOS)) {
                    Input(title: mealNameTitle.capitalized, field: $meal.name, message: $meal.nameMessage, topSpace: 0)
                    InputTitle(title: mealDescTitle.capitalized, buttonImage: AnyView(Image(systemName: "icloud.and.arrow.down").foregroundColor(Palette.background.themeText).font(.callout)), buttonAction: ($meal.url.wrappedValue == "" ? nil : { getDetail() }))
                    Input(field: $meal.desc, height: 60)
                    MealEditView_Categories(meal: meal)
                    ImageCaptureGroup(title: mealImageTitle.capitalized, image: $meal.image)
                    Input(title: mealUrlTitle.capitalized, field: $meal.url, height: 60, keyboardType: .URL, autoCapitalize: .none, autoCorrect: false)
                    Input(title: mealNotesTitle.capitalized, field: $meal.notes, height: 120)
                    Spacer()
                }
                .alert(isPresented: $saveError, content: {
                    Alert(title: Text("Error!"),
                          message: Text(meal.saveMessage))
                })
                NavigationLink(destination: AttachmentView(meal: meal, title: editAttachmentsName), isActive: $linkToAttachments) { EmptyView() }
            }
            .onChange(of: meal.url, perform: { value in
                // Invalidate image cache if URL changes
                meal.urlImageCache = nil
            })
            .onSwipe(.right) {
                if self.save() {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func save() -> Bool {
        if meal.mealMO == nil && meal.name == "" {
            return true
        } else {
            if self.meal.canSave { self.meal.save() }
            saveError = !self.meal.canSave
            return !saveError
        }
    }
    
    private func getDetail() {
        #if canImport(UIKit)
        LinkPresentation.getDetail(url: URL(string: meal.url)!) { (result) in
            switch result {
            case .success(let (_,title)):
                Utility.mainThread {
                    if let title = title {
                        meal.desc = title
                    }
                }
            default:
                break
            }
        }
        #endif
    }
    
    private func delete() -> Alert {
        return Alert(title: Text("Warning!"),
              message: Text("Are you sure you want to delete this \(mealName)?\n\nAny allocations of this meal in the calendar will be removed."),
              primaryButton:
                .destructive(Text("Delete")) {
                    self.meal.remove()
                    self.presentationMode.wrappedValue.dismiss()
                },
              secondaryButton:
                .cancel())
    }
}

struct MealEditView_Categories : View {
    
    @ObservedObject var meal: MealViewModel

    var width: CGFloat = 105
    let extraHeight: CGFloat = (MyApp.target == .macOS ? 16 : 0)
    var height: CGFloat = 32

    var body: some View {
        InputTitle(title: "Categories")
        ScrollView(.horizontal, showsIndicators: MyApp.target == .macOS) {
            let categories = self.getCategories()
            VStack {
                HStack {
                    ForEach(categories) { category in
                        let value = meal.categoryValues[category.categoryId]
                        let title = value?.name ?? category.name.uppercased()
                        let values = self.getCategoryValues(categoryId: category.categoryId)
                        let names = values.map{$0.name} + ["Not specified"]
                        
                        Menu(title) {
                            ForEach(0..<(names.count)) { (index) in
                                Button(names[index]) {
                                    meal.categoryValues[category.categoryId] = (index == names.count - 1 ? nil : values[index])
                                }
                            }
                        }.foregroundColor(value == nil ? Palette.disabledButton.faintText : Palette.enabledButton.text)
                        .font(value == nil ? .caption : .callout)
                        .frame(width: width, height: height)
                        .background(value == nil ? Palette.disabledButton.background : Palette.enabledButton.background)
                        .cornerRadius(height/2)
                    }
                }
                Spacer()
            }
        }
        .frame(height: height + extraHeight)
        .padding(.leading, 32)
        .padding(.trailing, 16)
    }
    
    func getCategories() -> [CategoryViewModel] {
        return DataModel.shared.categories.map{$1}.sorted(by: {Utility.lessThan([$0.importance.rawValue, $0.name], [$1.importance.rawValue, $1.name], [.int, .string])})
    }
    
    func getCategoryValues(categoryId: UUID) -> [CategoryValueViewModel] {
        return (DataModel.shared.categoryValues[categoryId] ?? [:]).map{$1}.sorted(by: {Utility.lessThan([$1.frequency.rawValue, $1.name], [$0.frequency.rawValue, $0.name], [.int, .string])})
    }
}

struct MealEditView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealEditView(meal: MealViewModel(name: "Macaroni Cheese", desc: "James Martin's ultimate macaroni cheese", url: "https://www.bbc.co.uk/food/recipes/james_martins_ultimate_60657", notes: ""), title: "Meal")
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            DataModel.shared.load()
        }
    }
}
