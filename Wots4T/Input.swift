//
//  Input.swift
//  Wots4T
//
//  Created by Marc Shearer on 10/02/2021.
//

import SwiftUI

struct Input : View {
    
    var title: String?
    @Binding var field: String
    var topSpace: CGFloat = 24
    var height: CGFloat = 40
    var onChange: ((String)->())?
    var keyboardType: UIKeyboardType = .default
    var autoCapitalize: UITextAutocapitalizationType = .sentences
    var autoCorrect: Bool = true
    
    var body: some View {

        VStack(spacing: 0) {
            if title != nil {
                InputTitle(title: title, topSpace: topSpace)
                Spacer().frame(height: 8)
            }
            HStack {
                Spacer().frame(width: 32)
                TextEditor(text: $field)
                    .lineLimit(1)
                    .padding(.all, 1)
                    .background(Palette.input.background)
                    .keyboardType(keyboardType)
                    .autocapitalization(autoCapitalize)
                    .disableAutocorrection(!autoCorrect)
                    .cornerRadius(8)
                Spacer().frame(width: 16)
            }
            .frame(height: self.height)
        }
    }
}
