//
//  Attachment View.swift
//  Wots4T
//
//  Created by Marc Shearer on 19/02/2021.
//

import SwiftUI

struct AttachmentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @ObservedObject var meal: MealViewModel
    
    @State var title: String
    @State private var image: Data?
     
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Banner(title: $title)
                Spacer()
                VStack {
                    Spacer()
                    ImageCaptureButton(image: $image, buttonImage: AnyView(Image(systemName: "plus.circle.fill").foregroundColor(.blue).font(.caption)))
                    Spacer().frame(height: 4)
                }
                .frame(height: 70)
                Spacer()
                    .frame(width: 16)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}
