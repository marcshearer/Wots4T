//
//  Picker.swift
//  Wots4T
//
//  Created by Marc Shearer on 14/02/2021.
//

import SwiftUI

struct PickerInput : View {
    
    var title: String?
    @Binding var field: Int
    var values: [String]
    var topSpace: CGFloat = 24
    var height: CGFloat = 40
    var onChange: ((String)->())?
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            InputTitle(title: title, topSpace: topSpace)
            HStack {
                Spacer().frame(width: 38)
                let label = HStack {
                    Text(values[field])
                    Spacer()
                    Image(systemName: "chevron.right")
                    Spacer().frame(width: 24)
                }
                Picker(selection: $field, label: label)
                {
                    ForEach(0..<values.count, id: \.self) { index in
                        Text(values[index])
                    }
                }
                .foregroundColor(.black)
                .pickerStyle(MenuPickerStyle())
                .lineLimit(1)
                .padding(.all, 1)
                Spacer()
            }
            .frame(height: self.height)
        }
    }
}
