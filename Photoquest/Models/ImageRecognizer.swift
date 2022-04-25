//
//  ImageRecognizer.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/24/22.
//

import UIKit
import CoreML
import Vision

protocol ImageRecognizerDelegate {
    func imageRecognizerDidFinish(image: UIImage, identifier: String, confidence: Int)
}

struct ImageRecognizer {
    
    var delegate: ImageRecognizerDelegate?
    
    func recognize(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            // TODO: Image Conversion Failure Handling
            return
        }
        
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model) else {
            // TODO: Failed To Load Model Handling
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                // TODO: No Results Error Handling
                return
            }
            
            DispatchQueue.main.async {
                let identifier = topResult.identifier.capitalized
                let confidence = Int(topResult.confidence * 100)
                delegate?.imageRecognizerDidFinish(image: image, identifier: identifier, confidence: confidence)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                // TODO: Request Failed Handling
                return
            }
        }
    }
    
}
