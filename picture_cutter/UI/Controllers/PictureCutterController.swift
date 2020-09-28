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
    @IBOutlet private weak var transformationView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    
    private let modelView = PictureCutterModelView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(gesture:)))
        rotateGesture.delegate = self
        imageView.addGestureRecognizer(rotateGesture)
            
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        rotateGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        imageView.addGestureRecognizer(pan)
        
        imageView.image = modelView.copyImage()
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        guard let image = modelView.drawImage(ctm: imageView.transform) else { return }
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
    @objc func handleRotate(gesture: UIRotationGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.changed || gesture.state == UIGestureRecognizer.State.began {           
            let transformRotate = imageView.transform.rotated(by: gesture.rotation)
            imageView.transform = transformRotate
            
            modelView.handleRotate(rotation: gesture.rotation)
            
            gesture.rotation = 0
        }
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.changed || gesture.state == UIGestureRecognizer.State.began {
            let scale = gesture.scale
            
            let transform = imageView.transform.scaledBy(x: scale, y: scale)
            imageView.transform = transform
            
            modelView.handlePinch(scale: scale)
            
            gesture.scale = 1
        }
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: transformationView)
        
        modelView.handlePan(translation: translation)
        
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: transformationView)
    }
}

extension PictureCutterController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
