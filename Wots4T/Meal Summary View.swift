//
//  Meal Summary View.swift
//  Wots4T
//
//  Created by Marc Shearer on 04/02/2021.
//

import SwiftUI

public struct MealSummaryView: View {
    @State var image: UIImage?

    var meal: MealViewModel
    var imageWidth: CGFloat?

    public var body: some View {
        HStack(alignment: .top) {
            Spacer().frame(width: 48)
            if let image = self.image {
                VStack {
                    Spacer()
                    Image(uiImage: image).resizable()
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
                    Text(meal.desc)
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
            if let url = meal.url {
                if let image = meal.urlImageCache {
                    // Used cached image
                    self.image = UIImage(data: image)
                } else {
                    // No cached image - derive from URL
                    LinkPresentation.getImage(url: URL(string: url)!) { (result) in
                        switch result {
                        case .success(let image):
                            self.image = image
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


