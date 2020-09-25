//
//  PictureCutterModelView.swift
//  picture_cutter
//
//  Created by Anastasia Nesterkina on 24.09.2020.
//  Copyright © 2020 Anastasia Nesterkina. All rights reserved.
//

import UIKit

class PictureCutterModelView {
    private var mainImage = UIImage(named: "dogs.jpg")
    private var scale: CGFloat = 1.0
    private var rotation: CGFloat = 0.0
    private var translation = CGPoint(x: 0.0, y: 0.0)
}

//MARK: Rendering
extension PictureCutterModelView {
    func copyImage() -> UIImage? {
        let contextSize = CGSize(width: 200, height: 200)
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        guard let image = mainImage, let cgImage = mainImage?.cgImage,
            let context = UIGraphicsGetCurrentContext()  else { return mainImage }
        let imageSize = newImageSize(image: image)
        
        context.saveGState()
        
        context.translateBy(x: 0.0, y: contextSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        
        let k = scaleCoefficient(contextSize: contextSize,
                                 imageSize: imageSize)
        
        context.scaleBy(x: k, y: k)
        
        let x0 = (contextSize.width / k - imageSize.width * scale) / 2.0
        let y0 = (contextSize.height / k - imageSize.height * scale) / 2.0
        
        context.draw(cgImage, in: CGRect(x: x0,
                                         y: y0,
                                         width: imageSize.width * scale,
                                         height: imageSize.height * scale))
        context.restoreGState()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func drawImage() -> UIImage?  {
        guard let image = mainImage else { return mainImage }
        var contextSize: CGSize
        let imageSize = image.size
        if imageSize.width > imageSize.height {
            contextSize = CGSize(width: imageSize.width,
                                 height: imageSize.width)
        } else {
            contextSize = CGSize(width: imageSize.height,
                                 height: imageSize.height)
        }
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
        guard let cgImage = image.cgImage,
            let context = UIGraphicsGetCurrentContext()  else { return mainImage }
        
        context.saveGState()
        
        context.translateBy(x: 0.0, y: contextSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let kScale = contextSize.width / 200
        
        context.translateBy(x: translation.x * kScale,
                            y: -translation.y * kScale)
        
        context.translateBy(x: contextSize.width / 2.0,
                            y: contextSize.height / 2.0)
        
        context.rotate(by: -rotation)
        
        context.translateBy(x: -contextSize.width / 2.0,
                            y: -contextSize.height / 2.0)
        
        
        let k = scaleCoefficient(contextSize: contextSize,
                                 imageSize: imageSize)
        
        context.scaleBy(x: k, y: k)
        
        let x0 = (contextSize.width / k - imageSize.width * scale) / 2.0
        let y0 = (contextSize.height / k - imageSize.height * scale) / 2.0
        
        context.draw(cgImage, in: CGRect(x: x0,
                                         y: y0,
                                         width: imageSize.width * scale,
                                         height: imageSize.height * scale))
        context.restoreGState()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    private func scaleCoefficient(contextSize: CGSize, imageSize: CGSize) -> CGFloat {
        var k: CGFloat = 1
        let kx: CGFloat = contextSize.width / imageSize.width
        
        if imageSize.width > contextSize.width && imageSize.height * kx < contextSize.height {
            k = kx
            
        } else if imageSize.height > contextSize.height {
            k = contextSize.height / imageSize.height
        }
        
        return k
    }
    
    private func newImageSize(image: UIImage) -> CGSize {
        var width = image.size.width
        var height = image.size.height
        var k: CGFloat = width / height
        
        if width > 1000 || height > 1000 {
            if width > height {
                k = width / 1000
                width = 1000
                height /= k
            } else {
                k = height / 1000
                height = 1000
                width /= k
            }
        }
        
        return CGSize(width: width, height: height)
    }
}

extension PictureCutterModelView {
    func handleRotate(rotation: CGFloat) {
        self.rotation += rotation
    }
    
    @objc func handlePinch(scale: CGFloat){
        self.scale *= scale
        translation.x *= scale
        translation.y *= scale
    }
    
    @objc func handlePan(translation: CGPoint) {
        self.translation.x += translation.x
        self.translation.y += translation.y
    }
}
