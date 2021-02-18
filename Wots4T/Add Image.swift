//
//  Add Image.swift
//  Wots4T
//
//  Created by Marc Shearer on 10/02/2021.
//

enum ImageSource {
    case camera
    case photoLibrary
    case pasteboard
    
    var pickerType: UIImagePickerController.SourceType? {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        default:
            return nil
        }
    }
}

import SwiftUI

struct AddImage : View {
    
    var title: String?
    @Binding var image: Data?
    @State var captureImage = false
    @State var source: ImageSource?
    
    var body: some View {

        VStack {
            InputTitle(title: title, topSpace: 24)
            Spacer().frame(height: 8)
            HStack {
                Spacer().frame(width: 32)
                if image == nil {
                    AddImage_Button(text: "Add", systemImage: "camera", width: 90, action: { (source) in
                        self.getImage(source: source)
                    })
                } else {
                    if let uiImage = UIImage(data: image!) {
                        VStack {
                            Spacer()
                            Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Spacer()
                        }.frame(maxWidth: 50)
                        Spacer().frame(width: 8)
                    }
                    AddImage_Button(text: "Replace", systemImage: "arrow.triangle.2.circlepath.camera", action: { (source) in
                        self.getImage(source: source)
                    })
                    Spacer().frame(width: 8)
                    AddImage_Button(text: "Remove", systemImage: "trash", capture: false, action: { (source) in
                        self.image = nil
                    })
                    Spacer().frame(width: 16)
                }
                Spacer()
            }
            .sheet(isPresented: $captureImage) {
                ImageCapture(image: $image, source: self.source!.pickerType!)
            }
        }
    }
    
    func getImage(source: ImageSource?) {
        if source != nil {
            self.source = source
            if source == .pasteboard {
                let pasteboard = UIPasteboard.general
                if pasteboard.hasImages {
                    self.image = pasteboard.image?.pngData() ?? nil
                }
                self.captureImage = false
            } else {
                self.captureImage = true
            }
        }
    }
}

struct AddImage_Button : View {
 
    var text: String
    var systemImage: String?
    var capture = true
    var width: CGFloat = 105
    var height: CGFloat = 32
    var action: (ImageSource)->()
    
    var body: some View {
        
        let camera = ImageCapture.isCameraAvailable && capture
        let photoLibrary =  ImageCapture.isPhotoLibraryAvailable && capture
        let pasteboard = UIPasteboard.general
        let paste = pasteboard.hasImages && capture
        
        if (camera ? 1 : 0) + (photoLibrary ? 1 : 0) + (paste ? 1 : 0) > 1 {
            Menu {
                if camera {
                    Button(action: {
                        action(.camera)
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                    }
                }
                if photoLibrary {
                    Button(action: {
                        action(.photoLibrary)
                    }) {
                        Image(systemName: "photo")
                        Text("Find in Photos")
                    }
                }
                if paste {
                    Button(action: {
                        action(.pasteboard)
                    }) {
                        Image(systemName: "doc.on.clipboard")
                        Text("Paste Image")
                    }
                }
            } label: {
                AddImage_Button_Content(text: text, systemImage: systemImage)
            }
            .frame(width: width, height: height)
                .background(Color.gray)
                .cornerRadius(height/2)
        } else {
            Button(action: {
                action(camera ? .camera : (photoLibrary ? .photoLibrary : .pasteboard))
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
            Spacer()
            Text(text)
                .foregroundColor(.white)
                .font(.callout)
                .minimumScaleFactor(0.5)
            Spacer()
        }
    }
}

struct AddImage_Previews: PreviewProvider {
    
    @State static var image: Data?
    
    static var previews: some View {
        Group {
            AddImage(title: mealImageTitle.capitalized, image: $image)
        }
    }
}
