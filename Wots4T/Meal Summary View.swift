//
//  Meal Summary View.swift
//  Wots4T
//
//  Created by Marc Shearer on 04/02/2021.
//

import SwiftUI

public struct MealSummaryView: View {
    
    @State var urlImage: UIImage?
    @ObservedObject var meal: MealViewModel
    var imageWidth: CGFloat?
    var showInfo: Bool = false
    
    @State private var linkToDisplay = false

    public var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 16)
            VStack {
                Spacer()
                if let imageData = $meal.image.wrappedValue, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else if let image = self.urlImage {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    Rectangle().foregroundColor(Palette.imagePlaceholder.background)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                Spacer()
            }.frame(maxWidth: self.imageWidth ?? 80)
            Spacer()
            VStack(spacing: 0) {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                        .frame(width: 8)
                    Text(meal.name)
                        .font(.title2)
                        .foregroundColor(Palette.background.text)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Spacer()
                        .frame(width: 8)
                    Text(meal.desc) // + "\n\(meal.debugInfo)")
                        .font(.subheadline)
                        .foregroundColor(Palette.background.contrastText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(height: 50, alignment: .top)
                    Spacer()
                }
                Spacer()
            }
            if showInfo {
                VStack {
                    Spacer()
                    Button(action: { linkToDisplay = true }) {
                        Image(systemName: "info.circle").font(.title2).foregroundColor(Palette.background.themeText)
                    }
                    Spacer()
                }
                Spacer().frame(width: 4)
            }
            Spacer().frame(width: 4)
            NavigationLink(destination: MealDisplayView(meal: meal), isActive: $linkToDisplay) { EmptyView() }
        }.onAppear {
            if meal.url != "" {
                if let image = meal.urlImageCache {
                    // Used cached image
                    self.urlImage = UIImage(data: image)
                } else {
                    // No cached image - derive from URL
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
                }
            }
        }
    }
}


