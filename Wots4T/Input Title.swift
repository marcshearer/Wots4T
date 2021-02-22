//
//  InputTitle.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct InputTitle : View {
    
    var title: String?
    var topSpace: CGFloat = 24
    var buttonImage: AnyView?
    var buttonText: String?
    var buttonAction: (()->())?
    
    var body: some View {

        VStack {
            Spacer().frame(height: topSpace)
                
            if let title = title {
                HStack(alignment: .center, spacing: nil) {
                    Spacer().frame(width: 16)
                    Text(title).font(.headline).foregroundColor(Palette.background.text)
                    
                    if let action = buttonAction {
                        Spacer().frame(width: 16)
                        Button {
                            action()
                        } label: {
                            if let image = buttonImage {
                                image
                            }
                            if let text = buttonText {
                                if buttonImage != nil {
                                    Spacer().frame(width: 8)
                                }
                                Text(text)
                                    .foregroundColor(Palette.background.themeText)
                            }
                        }
                        .menuStyle(DefaultMenuStyle())
                    }
                    Spacer()
                }
            }
        }
    }
}
