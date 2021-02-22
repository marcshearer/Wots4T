//
//  Separator.swift
//  Wots4T
//
//  Created by Marc Shearer on 22/02/2021.
//

import SwiftUI

struct Separator : View {
    
    @State var padding = true
    
    var body : some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundColor(Palette.separator.background)
            .padding(.leading, padding ? 24 : 0)
            .padding(.trailing, padding ? 12 : 0)
    }
}
