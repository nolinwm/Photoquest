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
    func imageRecognizerDidFinish(image: UIImage, identifiers: [String], confidence: Int)
}

struct ImageRecognizer {
    
    var delegate: ImageRecognizerDelegate?
    
    func recognize(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            // TODO: Image Conversion Failure Handling
            return
        }
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet(configuration: MLModelConfiguration()).model) else {
            // TODO: Failed To Load Model Handling
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                // TODO: No Results Error Handling
                return
            }
            DispatchQueue.main.async {
                let identifier = topResult.identifier.lowercased()
                let confidence = Int(topResult.confidence * 100)
                delegate?.imageRecognizerDidFinish(
                    image: image,
                    identifiers: identifier.components(separatedBy: ", "),
                    confidence: confidence
                )
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                // TODO: Request Failed Handling
                return
            }
        }
    }
    
}
