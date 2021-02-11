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
    
    var body: some View {

        VStack {
            Spacer().frame(height: topSpace)
                
            if let title = title {
                HStack {
                    Spacer().frame(width: 16)
                    Text(title).font(.headline)
                    Spacer()
                }
            }

            HStack {
                Spacer().frame(width: 32)
                TextEditor(text: $field)
                    .lineLimit(1)
                    .padding(.all, 1)
                    .background(Color(.lightGray))
                Spacer().frame(width: 16)
            }
            .frame(height: self.height)
        }
    }
}
