//
//  Input.swift
//  Wots4T
//
//  Created by Marc Shearer on 10/02/2021.
//

import SwiftUI

struct Input : View {
    
    #if canImport(UIKit)
    typealias KeyboardType = UIKeyboardType
    #else
    enum KeyboardType {
        case `default`
        case URL
    }
    #endif
    
    #if canImport(UIKit)
    typealias CapitalizationType = UITextAutocapitalizationType
    #else
    enum CapitalizationType {
        case sentences
        case none
    }
    #endif
    
    var title: String?
    @Binding var field: String
    var message: Binding<String>?
    var topSpace: CGFloat = 24
    var height: CGFloat = 50
    var onChange: ((String)->())?
    var keyboardType: KeyboardType = .default
    var autoCapitalize: CapitalizationType = .sentences
    var autoCorrect: Bool = true

    var body: some View {

        VStack(spacing: 0) {
            if title != nil {
                InputTitle(title: title, message: message, topSpace: topSpace)
                Spacer().frame(height: 8)
            }
            HStack {
                Spacer().frame(width: 32)
                TextEditor(text: $field)
                    .background(Palette.input.background)
                    .lineLimit(1)
                    .padding(.all, 1)
                    .keyboardType(self.keyboardType)
                    .autocapitalization(autoCapitalize)
                    .disableAutocorrection(!autoCorrect)
                    .cornerRadius(8)
                Spacer().frame(width: 16)
            }
        }
        .frame(height: self.height + self.topSpace + (title == nil ? 0 : 30))
    }
}
