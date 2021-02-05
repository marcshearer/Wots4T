//
//  Rich Links.swift
//  Wots4T
//
//  Created by Marc Shearer on 04/02/2021.
//

import LinkPresentation
import UIKit
import SwiftUI

class LinkPresentation {
    
    static func getImage(url: URL, completion: @escaping (Result<UIImage, Error>)->()) {
        
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let metadata = metadata, let imageProvider = metadata.imageProvider {
                    imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            let uiImage = image as? UIImage ?? UIImage()
                            completion(.success(uiImage))
                        }
                    }
                }
            }
        }
    }
}

struct LinkView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var metadata: LPLinkMetadata?
    var frame: CGRect
    
    func makeUIView(context: Context) -> UIView {
        let imageView = UIImageView(frame: frame)
        
        if let metadata = metadata, let imageProvider = metadata.imageProvider {
            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if error == nil {
                    if let image = image as? UIImage {
                        imageView.image = image
                    }
                }
            }
        }
        return imageView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
