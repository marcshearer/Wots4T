//
//  Meal Summary View.swift
//  Wots4T
//
//  Created by Marc Shearer on 04/02/2021.
//

import SwiftUI

public struct MealSummaryView: View {
    
    @State var urlImage: MyImage?
    @ObservedObject var meal: MealViewModel
    var imageWidth: CGFloat?
    var showInfo: Bool = false
    
    @State private var linkToDisplay = false

    public var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 16)
            MealView(name: meal.name, desc: meal.desc, imageData: meal.image, urlImageData: meal.urlImageCache, imageWidth: imageWidth ?? 80)
            if showInfo {
                VStack {
                    Spacer()
                    Button(action: { linkToDisplay = true }) {
                        Image(systemName: "info.circle").font(.title2).foregroundColor(Palette.background.themeText)
                    }
                    Spacer()
                }
                Spacer().rightSpacer
            }
            Spacer().frame(width: 4)
            NavigationLink(destination: MealDisplayView(meal: meal), isActive: $linkToDisplay) { EmptyView() }
        }.onAppear {
            if meal.url != "" {
                if let image = meal.urlImageCache {
                    // Used cached image
                    self.urlImage = MyImage(data: image)
                } else {
                    // No cached image - derive from URL
                    #if canImport(UIKit)
                    // TODO Need MacOS equivalent
                    LinkPresentation.getDetail(url: URL(string: meal.url)!, getImage: true) { (result) in
                        switch result {
                        case .success(let (image,_)):
                            Utility.mainThread {
                                self.urlImage = image
                                meal.saveimageCache(image: image)
                            }
                        default:
                            break
                        }
                    }
                    #endif
                }
            }
        }
    }
}


