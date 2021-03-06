//
//  PictureCutterModelView.swift
//  picture_cutter
//
//  Created by Anastasia Nesterkina on 24.09.2020.
//  Copyright © 2020 Anastasia Nesterkina. All rights reserved.
//

import UIKit

class PictureCutterViewModel {
    private var mainImage = UIImage(named: "dogs.jpg")
}

//MARK: Rendering
extension PictureCutterViewModel {
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
        
        let x0 = (contextSize.width / k - imageSize.width) / 2.0
        let y0 = (contextSize.height / k - imageSize.height) / 2.0
        
        context.draw(cgImage, in: CGRect(x: x0,
                                         y: y0,
                                         width: imageSize.width,
                                         height: imageSize.height))
        context.restoreGState()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func drawImage(ctm: CGAffineTransform) -> UIImage?  {
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
               
        let kScale = contextSize.width / 200
        let scaleTransform = CGAffineTransform(scaleX: kScale, y: kScale)
        
        let centerTransform = CGAffineTransform(translationX: contextSize.width / 2,
                                                y: contextSize.height / 2)
        
        let translateTransform = CGAffineTransform(translationX: (contextSize.width - imageSize.width) / 2,
                                                   y: (contextSize.height - imageSize.height) / 2)     
        
        let upsideDown = CGAffineTransform(scaleX: 1, y: -1)
            .concatenating(CGAffineTransform(translationX: 0,
                                             y: CGFloat(contextSize.height)))
        
        
        context.saveGState()

        context.concatenate(centerTransform)
        context.concatenate(scaleTransform)
        context.concatenate(ctm)
        context.concatenate(scaleTransform.inverted())
        context.concatenate(centerTransform.inverted())
        
        context.concatenate(upsideDown)
        context.concatenate(translateTransform)

        context.draw(cgImage, in: CGRect(x: 0,
                                         y: 0,
                                         width: imageSize.width,
                                         height: imageSize.height))
        
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
