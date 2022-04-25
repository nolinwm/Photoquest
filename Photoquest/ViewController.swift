//
//  ViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/24/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageRecognizerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    let imageController = UIImagePickerController()
    var imageRecognizer = ImageRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageController.allowsEditing = false
        imageController.sourceType = .camera
        imageController.delegate = self
        
        imageRecognizer.delegate = self
        
        imageView.layer.cornerRadius = 20
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        present(imageController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            // TODO: Failed To Load Image Error Handling
            return
        }
        
        imageView.image = image
        cameraButton.isEnabled = false
        label.text = "Identifying image..."
        
        imageRecognizer.recognize(image: image)
    }
    
    func imageRecognizerDidFinish(image: UIImage, identifier: String, confidence: Int) {
        cameraButton.isEnabled = true
        label.text = "\(identifier) (\(confidence)%)"
    }
}

