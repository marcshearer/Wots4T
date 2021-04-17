//
//  Meal View.swift
//  Wots4T
//
//  Created by Marc Shearer on 15/04/2021.
//

import SwiftUI

struct MealView : View {
    var title: String?
    var name: String
    var desc: String?
    var imageData: Data?
    var urlImageData: Data?
    var imageOnly = false
    var height: CGFloat = 80
    var imageWidth: CGFloat = 80

    var body: some View {
        HStack {
            VStack {
                if !imageOnly {
                    Spacer()
                }
                if let imageData = imageData, let image = MyImage(data: imageData) {
                    Image(myImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageWidth)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else if let imageData = urlImageData, let image = MyImage(data: imageData) {
                    Image(myImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageWidth)
                        .clipShape(RoundedRectangle(cornerRadius: (imageOnly ? 0 : 5)))
                } else {
                    if imageOnly {
                        VStack {
                            Spacer()
                            Text(name)
                                .font(.headline)
                                .minimumScaleFactor(0.7)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .foregroundColor(Palette.imagePlaceholder.text)
                            Spacer()
                        }
                        .frame(width: imageWidth)
                        .background(Palette.imagePlaceholder.background)
                    } else {
                        Rectangle()
                            .foregroundColor(Palette.imagePlaceholder.background)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                if !imageOnly {
                    Spacer()
                }
            }
            .frame(maxWidth: imageWidth)
            
            if !imageOnly {
                let titleHeight: CGFloat = (title == nil ? 0 : height * 0.33)
                let nameHeight: CGFloat = (desc == nil ? height - titleHeight : 20)
                let descHeight: CGFloat = height - titleHeight - nameHeight
                Spacer()
                VStack(spacing: 0) {
                    if let title = title {
                        Spacer().frame(height: 12)
                        HStack {
                            Spacer()
                                .frame(width: 8)
                            Text(title)
                                .font(.title3)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(Palette.background.themeText)
                                .lineLimit(1)
                            Spacer()
                        }
                        .frame(height: titleHeight - 16)
                        Spacer().frame(height: 4)
                    }
                    
                    Spacer().frame(height: 8)
                    HStack {
                        Spacer()
                            .frame(width: 8)
                        Text(name)
                            .font(title == nil ? .title2 : .callout)
                            .foregroundColor(Palette.background.text)
                            .multilineTextAlignment(.leading)
                            .lineLimit(desc == nil ? 2 : 1)
                        Spacer()
                    }
                    .frame(height: nameHeight - 8)
                    
                    if let desc = desc {
                        Spacer().frame(height: 8)
                        VStack {
                            HStack {
                                Spacer()
                                    .frame(width: 8)
                                Text(desc)
                                    .font(.subheadline)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(Palette.background.contrastText)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(height: descHeight - 8)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: height)
    }
}
