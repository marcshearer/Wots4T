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
    #if canImport(UIKit)
    @State private var editMode = EditMode.active
    #else
    @State private var editMode: Bool = true
    #endif
    
    var body: some View {
        
        StandardView {
            VStack {
                HStack {
                    Banner(title: $title)
                    Spacer()
                    VStack {
                        Spacer()
                        ImageCaptureButton(image: $image, buttonContent: AnyView(Image(systemName: "plus.circle.fill")
                                                                                    .foregroundColor(.blue)
                                                                                    .font(.largeTitle)))
                            .onChange(of: image, perform: { image in
                                if let image = image {
                                    let sequence = meal.attachments.last?.sequence ?? 0
                                    meal.attachments.append(AttachmentViewModel(sequence: sequence, attachment: image))
                                    meal.save()
                                }
                            })
                        Spacer().frame(height: 4)
                    }
                    .frame(height: 70)
                    Spacer()
                        .frame(width: 16)
                }
                List {
                    ForEach(meal.attachments) { (attachment) in
                        Image(myImage: MyImage(data: attachment.attachment!)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 80)
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                }
                .editMode($editMode)
                Spacer()
            }
        }
        .onSwipe(.right) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onDelete(offsets: IndexSet) {
        for index in offsets.reversed() {
            meal.attachments.remove(at: index)
        }
        meal.save()
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        meal.attachments.move(fromOffsets: source, toOffset: destination)
        for (index, attachment) in meal.attachments.enumerated() {
            attachment.sequence = index
        }
        meal.save()
    }
}
