//
// Banner.swift
//  Wots4T
//
//  Created by Marc Shearer on 05/02/2021.
//

import SwiftUI

struct BannerOption {
    let image: AnyView?
    let text: String?
    let action: ()->()
    
    init(image: AnyView? = nil, text: String? = nil, action: @escaping ()->()) {
        self.image = image
        self.text = text
        self.action = action
    }
}

enum BannerOptionMode {
    case menu
    case buttons
    case none
}

struct Banner: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var title: String
    var back: Bool = true
    var backCheck: (()->(Bool))? = nil
    var optionMode: BannerOptionMode = .none
    var menuImage: AnyView? = nil
    var options: [BannerOption]? = nil
       
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer().frame(width: 16)
                if back {
                    backButton
                }
                Text(title).font(.largeTitle).bold()
                Spacer()
                switch optionMode {
                case .menu:                    Banner_Menu(image: menuImage, options: options!)
                case .buttons:
                    Banner_Buttons(options: options!)
                default:
                    EmptyView()
                }
            }
        }
        .frame(height: 70)
    }
    
    var backButton: some View {
        Button(action: {
            var backOk = true
            if let backCheck = self.backCheck {
                backOk = backCheck()
            }
            if backOk {
                self.presentationMode.wrappedValue.dismiss()
            }
        }, label: {
            HStack {
                Image(systemName: "chevron.left").font(.largeTitle)
            }
        })
    }
}

struct Banner_Menu : View {
    var image: AnyView?
    var options: [BannerOption]

    var body: some View {
        let menuLabel = image ?? AnyView(Image(systemName: "line.horizontal.3").foregroundColor(.black).font(.largeTitle))
        Menu {
            ForEach(0..<(options.count)) { (index) in
                let option = options[index]
                Button {
                    option.action()
                } label: {
                    if option.image != nil {
                        option.image
                    }
                    if option.image != nil && option.text != nil {
                        Spacer().frame(width: 16)
                    }
                    if option.text != nil {
                        Text(option.text!)
                    }
                }.menuStyle(DefaultMenuStyle())
            }
        } label: {
            menuLabel
        }
        Spacer().frame(width: 16)
    }
}

struct Banner_Buttons : View {
    var options: [BannerOption]

    var body: some View {
        HStack {
            ForEach(0..<(options.count)) { (index) in
                let option = options[index]
                Button {
                    option.action()
                } label: {
                    if option.image != nil {
                        option.image
                    }
                    if option.image != nil && option.text != nil {
                        Spacer().frame(width: 16)
                    }
                    if option.text != nil {
                        Text(option.text ?? "")
                    }
                }.menuStyle(DefaultMenuStyle())
            }
        }
        Spacer().frame(width: 16)
    }
}
