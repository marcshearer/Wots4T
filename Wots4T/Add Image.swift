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

enum ImageButtonType {
    case add
    case replace
    case remove
    
    var text: String {
        switch self {
        case .add:
            return "Add"
        case .replace:
            return "Replace"
        case .remove:
            return "Remove"
        }
    }
    
    var imageName: String {
        switch self {
        case .add:
            return "camera"
        case .replace:
            return "arrow.triangle.2.circlepath.camera"
        case .remove:
            return"trash"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .add:
            return 90
        default:
            return 105
        }
    }
    
    var image: AnyView {
        return AnyView(Image(systemName: self.imageName).foregroundColor(.white).font(.callout))
    }

}
import SwiftUI

struct ImageCaptureGroup : View {
    
    var title: String?
    @Binding var image: Data?
    
    var body: some View {

        VStack {
            InputTitle(title: title, topSpace: 24)
            Spacer().frame(height: 8)
            HStack {
                Spacer().frame(width: 32)
                if image == nil {
                    ImageCaptureButton(image: $image, text: ImageButtonType.add.text, type: .add, width: ImageButtonType.add.width)
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
                    ImageCaptureButton(image: $image, text: ImageButtonType.replace.text, type: .replace, width: ImageButtonType.replace.width)
                    Spacer().frame(width: 8)
                    ImageCaptureButton(image: $image, text: ImageButtonType.remove.text, type: .remove, width: ImageButtonType.remove.width)
                    Spacer().frame(width: 16)
                }
                Spacer()
            }
        }
    }
}

struct ImageCaptureButton : View {
    @Binding var image: Data?
    @State var buttonContent: AnyView?
    @State var text: String?
    @State var type: ImageButtonType = .add
    @State var width: CGFloat?
    @State var height: CGFloat?
    @State private var source: ImageSource?
    @State private var captureImage = false

    var body: some View {
        
        HStack(spacing: 0) {
            let buttonContent = self.buttonContent ?? AnyView(ImageCaptureButton_GetSource_Content(type: type))
            switch type {
            case .add:
            ImageCaptureButton_GetSource(text: text, buttonContent: buttonContent, action: { (source) in
                    self.getImage(source: source)
                })
            case .replace:
                ImageCaptureButton_GetSource(text: text, buttonContent: buttonContent, action: { (source) in
                    self.getImage(source: source)
                })
            case .remove:
                ImageCaptureButton_GetSource(text: text, buttonContent: buttonContent, capture: false, action: { (source) in
                    self.image = nil
                })
            }
        }
        .sheet(isPresented: $captureImage) {
            if let source = source {
                ImageCapture(image: $image, source: source.pickerType!)
            }
        }
    }
    
    func getImage(source: ImageSource?) {
        if source != nil {
            self.captureImage = false
            self.source = source
            if source == .pasteboard {
                let pasteboard = UIPasteboard.general
                if pasteboard.hasImages {
                    self.image = pasteboard.image?.pngData() ?? nil
                }
            } else {
                self.captureImage = true
            }
        }
    }
}

fileprivate struct ImageCaptureButton_GetSource : View {
 
    var text: String?
    var buttonContent: AnyView?
    var capture = true
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
                buttonContent
            }
        } else {
            Button(action: {
                action(camera ? .camera : (photoLibrary ? .photoLibrary : .pasteboard))
            }) {
                buttonContent
            }
        }
    }
}

fileprivate struct ImageCaptureButton_GetSource_Content : View {
    
    var type: ImageButtonType
    private let height: CGFloat = 32
    
    var body: some View {
        HStack {
            Spacer().frame(width: 8)
            type.image
            Spacer()
            Text(type.text)
                .foregroundColor(Palette.enabledButton.text)
                .font(.callout)
                .minimumScaleFactor(0.5)
            Spacer()
        }
        .frame(width: type.width, height: height)
        .background(Palette.enabledButton.background)
        .cornerRadius(height/2)
    }
}

struct AddImage_Previews: PreviewProvider {
    
    @State static var image: Data?
    
    static var previews: some View {
        Group {
            ImageCaptureGroup(title: mealImageTitle.capitalized, image: $image)
        }
    }
}
