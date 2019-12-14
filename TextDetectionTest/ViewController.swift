//
//  ViewController.swift
//  TextDetectionTest
//
//  Created by 荒居秀尚 on 13.12.19.
//  Copyright © 2019 荒居秀尚. All rights reserved.
//

import UIKit
import Vision
import CoreML
import ImageIO

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentImage: UIImage!

    @IBOutlet weak var imageView: UIImageView!

    @IBAction func chooseImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let uiImage = info[.originalImage] as? UIImage else {
            fatalError("no image from image picker")
        }
        guard let cgImage = uiImage.cgImage else {
            fatalError("can't create CIImage from UIImage")
        }
        self.imageView.image = uiImage
        self.currentImage = uiImage
        
        let request = VNRecognizeTextRequest(completionHandler: self.detectTextHandler)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = false
        
        let requests = [request]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try! imageRequestHandler.perform(requests)
    }
    
    func detectTextHandler(request: VNRequest?, error: Error?) {
        guard let observations = request?.results as? [VNRecognizedTextObservation] else {
            return
        }
        var boundingBoxes = [CGRect]()
        var texts = [String]()
        var points = [CGPoint]()

        let height = self.currentImage.size.height
        let width = self.currentImage.size.width
        
        for observation in observations {
            let candidates = 1
            guard let bestCandidate = observation.topCandidates(candidates).first else {
                continue
            }

            let bbox = observation.boundingBox
            boundingBoxes.append(
                CGRect(
                    x: bbox.origin.x * width,
                    y: (1.0 - bbox.origin.y - bbox.height) * height,
                    width: bbox.width * width,
                    height: bbox.height * height)
            )
            
            texts.append(bestCandidate.string)
            points.append(
                CGPoint(
                    x: bbox.origin.x * width,
                    y: (1.0 - bbox.origin.y - bbox.height) * height
            ))
        }
        
        let newImage = self.currentImage.drawBoundingBox(boundingBoxes: boundingBoxes)
        self.imageView.image = newImage!.drawDetectedText(texts: texts, points: points)
    }
}

