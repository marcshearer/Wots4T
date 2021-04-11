//
//  Meal Display View.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/02/2021.
//

import SwiftUI

struct MealDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        StandardView {
            VStack(spacing: 0) {
                MealDisplayView_Banner(meal: meal)
                ScrollView(showsIndicators: MyApp.target == .macOS) {
                    VStack(spacing: 0) {
                        MealDisplayView_Image(meal: meal)
                        MealDisplayView_Description(meal: meal)
                        MealDisplayView_Notes(meal: meal)
                        MealDisplayView_Attachments(meal: meal)
                    }
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .onSwipe(.right) {
                presentationMode.wrappedValue.dismiss()
            }
            .onTapGesture {
                MealDisplayView.browseUrl(url: meal.url)
            }
        }
    }
    
    fileprivate static func browseUrl(url: String) {
        #if canImport(UIKit)
        if let url = URL.init(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #else
        if let url = URL.init(string: url) {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

struct MealDisplayView_Banner: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        let options: [BannerOption] = (meal.url == "" ? [] : [
                BannerOption(
                    image: AnyView(Image("online").resizable().frame(width: 30, height: 30).font(.largeTitle).foregroundColor(Palette.banner.themeText)),
                    action: {
                        MealDisplayView.browseUrl(url: meal.url)
                    })])
        
        Banner(title: $meal.name,
               optionMode: .buttons,
               options: options)
        Spacer().frame(height: 16)

    }
}

struct MealDisplayView_Image: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        
        if let imageData = $meal.image.wrappedValue, let image = MyImage(data: imageData) {
            VStack {
                Image(myImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        } else if let imageData = meal.urlImageCache, let image = MyImage(data: imageData) {
            VStack {
                Image(myImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}

struct MealDisplayView_Description: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        
        if meal.desc != "" {
            HStack {
                Spacer()
                Text(meal.desc)
                    .font(.headline)
                    .bold()
                    .padding(.all, 16)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Palette.divider.text)
                Spacer()
            }.background(Palette.divider.background)
        }
    }
}

struct MealDisplayView_Notes: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        
        if meal.notes != "" {
            ZStack {
                Rectangle()
                    .foregroundColor(Palette.alternate.background)
                VStack {
                    Text(meal.notes)
                        .font(.body)
                        .padding(.all, 16)
                        .foregroundColor(Palette.alternate.text)
                    Spacer()
                }
            }
        }
    }
}

struct MealDisplayView_Attachments: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        
        VStack {
            ForEach(meal.attachments) { (attachment) in
                Image(myImage: MyImage(data: attachment.attachment!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}

struct MealDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MealDisplayView(meal: MealViewModel(name: "Macaroni Cheese", desc: "James Martin's ultimate macaroni cheese", url: "https://www.bbc.co.uk/food/recipes/james_martins_ultimate_60657", notes: ""))
        }.onAppear {
            CoreData.context = PersistenceController.preview.container.viewContext
            MasterData.shared.load()
        }
    }
}
