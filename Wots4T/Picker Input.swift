//
//  Picker.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct PickerInput : View {
    
    var title: String
    @Binding var field: Int
    var values: [String]
    var topSpace: CGFloat = 24
    var width: CGFloat = 200
    var height: CGFloat = 40
    var onChange: ((String)->())?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InputTitle(title: title, topSpace: topSpace)
            HStack {
                Spacer().frame(width: 38)
                Menu {
                    ForEach(0..<(values.count)) { (index) in
                        Button(values[index]) {
                            field = index
                        }
                    }
                } label: {
                    HStack {
                        Text(values[field])
                            .foregroundColor(Palette.background.text)
                            .font(.callout)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Palette.background.themeText)
                        Spacer().frame(width: 24)
                    }
                }
                .frame(width: width, height: height)
                .background(Color.clear)
                .frame(height: self.height)
                
            }
        }
    }
}
