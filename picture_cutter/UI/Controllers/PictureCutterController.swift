//
//  LaunchScreenController.swift
//  picture_cutter
//
//  Created by Anastasia Nesterkina on 22.09.2020.
//  Copyright © 2020 Anastasia Nesterkina. All rights reserved.
//

import Foundation
import UIKit
    
class PictureCutterController: UIViewController, Storyboarded {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    private var scale: CGFloat = 1
    
    private let modelView = PictureCutterViewModel()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(recognizer:)))
            rotateGesture.delegate = self
            containerView.addGestureRecognizer(rotateGesture)
                
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
            rotateGesture.delegate = self
            containerView.addGestureRecognizer(pinchGesture)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
            containerView.addGestureRecognizer(pan)
            
            imageView.image = modelView.copyImage()
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        guard let image = modelView.drawImage(ctm: imageView.transform, scale: scale) else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
           
    }
    
    //MARK: - Add image to Library
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    private func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}

  //MARK: - UIGestureRecognizers
private extension PictureCutterController {
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        let rotation = CGAffineTransform(rotationAngle: recognizer.rotation)
        let transform = imageView.transform.concatenating(rotation)
        
        imageView.transform = transform

        recognizer.rotation = 0
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        let scale = CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale)
        let transform = imageView.transform.concatenating(scale)

        imageView.transform = transform
        self.scale *= recognizer.scale
        recognizer.scale = 1
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let view = containerView
        let offset = recognizer.translation(in: view)
        let translation = CGAffineTransform(translationX: offset.x, y: offset.y)
        let transform = imageView.transform.concatenating(translation)
        
        imageView.transform = transform
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
}

extension PictureCutterController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
