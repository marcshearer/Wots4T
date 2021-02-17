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
        VStack(spacing: 0) {
            MealDisplayView_Banner(meal: meal)
            MealDisplayView_Image(meal: meal)
            MealDisplayView_Description(meal: meal)
            MealDisplayView_Notes(meal: meal)
            Spacer()
        }.edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onTapGesture {
            MealDisplayView.browseUrl(url: meal.url)
        }
    }
    
    fileprivate static func browseUrl(url: String) {
        if let url = URL.init(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct MealDisplayView_Banner: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        let options: [BannerOption] = (meal.url == "" ? [] : [
                BannerOption(
                    image: AnyView(Image(systemName: "eye").font(.largeTitle).foregroundColor(.blue)),
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
        
        if let imageData = $meal.image.wrappedValue, let image = UIImage(data: imageData) {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if let imageData = meal.urlImageCache, let image = UIImage(data: imageData) {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
                    .foregroundColor(.white)
                Spacer()
            }.background(Color(.black))
        }
    }
}

struct MealDisplayView_Notes: View {

    @ObservedObject var meal: MealViewModel
    
    var body: some View {
        
        if true || meal.notes != "" {
            ZStack {
                VStack {
                    Text(meal.notes)
                        .font(.body)
                        .padding(.all, 16)
                    Spacer()
                }
                Rectangle()
                    .foregroundColor(Color(.black).opacity(0.03))
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
            DataModel.shared.load()
        }
    }
}
