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

    public var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 48)
            if let imageData = $meal.image.wrappedValue, let image = UIImage(data: imageData) {
                VStack {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }.frame(maxWidth: self.imageWidth ?? 80)
                Spacer()
            } else if let image = self.urlImage {
                VStack {
                    Spacer()
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }.frame(maxWidth: self.imageWidth ?? 80)
                Spacer()
            }
            VStack(spacing: 0) {
                Spacer().frame(height: 4)
                HStack {
                    Spacer()
                        .frame(width: 8)
                    Text(meal.name)
                        .font(.title2)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Spacer()
                        .frame(width: 8)
                    Text(meal.desc) // + "\n\(meal.debugInfo)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .frame(height: 50, alignment: .top)
                    Spacer()
                }
                Spacer()
            }
        }.onAppear {
            if meal.url != "" {
                if let image = meal.urlImageCache {
                    // Used cached image
                    self.urlImage = UIImage(data: image)
                } else {
                    // No cached image - derive from URL
                    LinkPresentation.getImage(url: URL(string: meal.url)!) { (result) in
                        switch result {
                        case .success(let image):
                            self.urlImage = image
                            meal.saveimageCache(image: image)
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
}


