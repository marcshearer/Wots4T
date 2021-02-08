//
// Banner.swift
//  Wots4T
//
//  Created by Marc Shearer on 05/02/2021.
//

import SwiftUI

struct Banner: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String
    var back: Bool = true
    var menuImage: AnyView?
    var menuAction: (()->())?
    var menuOptions: [(text: String, action: (()->())?)]?
    
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
                Banner_Menu(menuImage: menuImage, menuAction: menuAction, menuOptions: menuOptions)
            }
        }
        .frame(height: 80)
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.left").font(.largeTitle)
            }
        })
    }
}

struct Banner_Menu : View {
    var menuImage: AnyView?
    var menuAction: (()->())?
    var menuOptions: [(text: String, action: (()->())?)]?

    var body: some View {
        let menuLabel = menuImage ?? AnyView(Image(systemName: "line.horizontal.3").foregroundColor(.black).font(.largeTitle))
        
        if menuAction != nil {
            Button(action: { menuAction?() }) {
                menuLabel
            }
        } else if menuOptions?.count ?? 0 > 0 {
            Menu {
                ForEach(0..<(menuOptions?.count ?? 1)) { (index) in
                    Button {
                        menuOptions?[index].action?()
                    } label: {
                        Text(menuOptions?[index].text ?? "")
                    }.menuStyle(DefaultMenuStyle())
                }
            } label: {
                menuLabel
            }
        }
        Spacer().frame(width: 16)
    }
}
