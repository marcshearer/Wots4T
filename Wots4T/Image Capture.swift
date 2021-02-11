//
//  Image Capture.swift
//  Wots4T
//
//  Created by Marc Shearer on 11/02/2021.
//

import SwiftUI
import UIKit

struct ImageCapture: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var isPresented

    @Binding var image: Data?
    var source: UIImagePickerController.SourceType

    static var isCameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    static var isPhotoLibraryAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = self.source
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> ImageCaptureCoordinator {
        return ImageCaptureCoordinator(source: self)
    }
    
    fileprivate func dismiss() {
        self.isPresented.wrappedValue.dismiss()
    }
}

class ImageCaptureCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var source: ImageCapture
    
    init(source: ImageCapture) {
        self.source = source
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.source.image = image.pngData()
            self.source.dismiss()
        }
    }
}
