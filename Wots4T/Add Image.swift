//
//  Add Image.swift
//  Wots4T
//
//  Created by Marc Shearer on 10/02/2021.
//

import SwiftUI

struct AddImage : View {
    
    var title: String?
    @Binding var image: Data?
    @State var captureImage = false
    @State var source: UIImagePickerController.SourceType!
    
    var body: some View {

        VStack {
            Spacer().frame(height: 24)
                
            if let title = title {
                HStack {
                    Spacer().frame(width: 16)
                    Text(title).font(.headline)
                    Spacer()
                }
                Spacer().frame(height: 4)
            }

            HStack {
                Spacer().frame(width: 32)
                if image == nil {
                    AddImage_Button(text: "Add", systemImage: "camera", width: 90, action: { (source) in
                        self.source = source
                        captureImage = (source != nil)
                    })
                } else {
                    AddImage_Button(text: "Replace", systemImage: "arrow.triangle.2.circlepath.camera", action: { (source) in
                        self.source = source
                        captureImage = (source != nil)
                    })
                    Spacer().frame(width: 16)
                    AddImage_Button(text: "Remove", systemImage: "trash", capture: false, action: { (source) in
                        self.image = nil
                    })
                    Spacer().frame(width: 16)
                }
                Spacer()
            }
            .sheet(isPresented: $captureImage) {
                ImageCapture(image: $image, source: self.source)
            }
        }
    }
}

struct AddImage_Button : View {
 
    var text: String
    var systemImage: String?
    var capture = true
    var width: CGFloat = 110
    var height: CGFloat = 32
    var action: (UIImagePickerController.SourceType?)->()
    
    var body: some View {
        
        let camera = ImageCapture.isCameraAvailable && capture
        let photoLibrary =  ImageCapture.isPhotoLibraryAvailable && capture
        
        if camera && photoLibrary {
            Menu {
                Button(action: {
                    action(.camera)
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                }
                Button(action: {
                    action(.photoLibrary)
                }) {
                    Image(systemName: "photo")
                    Text("Find in Photos")
                }
            } label: {
                AddImage_Button_Content(text: text, systemImage: systemImage)
            }
            .frame(width: width, height: height)
                .background(Color.gray)
                .cornerRadius(height/2)
        } else {
            Button(action: {
                action(camera ? .camera : (photoLibrary ? .photoLibrary : .none))
            }) {
                AddImage_Button_Content(text: text, systemImage: systemImage)
            }
            .frame(width: width, height: height)
                .background(Color.gray)
                .cornerRadius(height/2)
        }
    }
}

struct AddImage_Button_Content : View {
    
    var text: String
    var systemImage: String?
    
    var body: some View {
        HStack {
            if let systemImage = systemImage {
                Spacer().frame(width: 8)
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.callout)
            }
            Spacer().frame(width: 8)
            Text(text)
                .foregroundColor(.white)
                .font(.callout)
            Spacer()
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    
    @State static var image: Data?
    
    static var previews: some View {
        Group {
            AddImage(title: imageTitle.capitalized, image: $image)
        }
    }
}
