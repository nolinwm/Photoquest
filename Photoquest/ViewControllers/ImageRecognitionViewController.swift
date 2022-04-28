//
//  ImageRecognitionViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

protocol ImageRecognitionViewControllerDelegate {
    func imageRecognitionViewControllerDidDismiss(imageWasAccepted: Bool, recaptureRequested: Bool)
}

class ImageRecognitionViewController: UIViewController {
    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var recaptureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var imageRecognizer = ImageRecognizer()
    
    var photo: Photo?
    var capturedImage: UIImage?
    
    var imageWasAccepted = false
    var recaptureRequested = false
    var delegate: ImageRecognitionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageRecognizer.delegate = self
        prepareForPresentation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        presentWithAnimation()
        startImageRecognition()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissWithAnimation()
    }
    
    @IBAction func doneButtonTaped(_ sender: Any) {
        dismissWithAnimation()
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        recaptureRequested = true
        dismissWithAnimation()
    }
}

// MARK: - Animation Methods
extension ImageRecognitionViewController {
    
    func prepareForPresentation() {
        label.text = nil
        dimView.alpha = .zero
        
        imageView.layer.cornerRadius = 20
        imageView.image = capturedImage
        imageView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        
        containerView.layer.cornerRadius = 12
        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        
        recaptureButton.isHidden = true
        cancelButton.isHidden = false
        doneButton.isHidden = true
    }
    
    private func presentWithAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimView.alpha = 0.75
        }
        
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 3, options: .curveEaseOut) {
            self.containerView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.125, usingSpringWithDamping: 0.75, initialSpringVelocity: 4, options: .curveEaseOut) {
            self.imageView.transform = .identity
        }
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        }
        
        UIView.animate(withDuration: 0.35, delay: 0.075, options: .curveEaseOut) {
            self.imageView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        } completion: { complete in
            self.dismiss(animated: false)
            self.delegate?.imageRecognitionViewControllerDidDismiss(
                imageWasAccepted: self.imageWasAccepted,
                recaptureRequested: self.recaptureRequested
            )
        }
    }
}

// MARK: - ImageRecognizer Methods
extension ImageRecognitionViewController: ImageRecognizerDelegate {

    func startImageRecognition() {
        guard let capturedImage = capturedImage else {
            dismiss(animated: false)
            return
        }
        activitySpinner.startAnimating()
        imageRecognizer.recognize(image: capturedImage)
    }
    
    func imageRecognizerDidFinish(image: UIImage, identifiers: [String], confidence: Int) {
        developerDisplayReturnedIdentifiers(identifiers)
        
        guard self.capturedImage == image, let photo = photo else {
            dismiss(animated: false)
            return
        }
        
        let matchedIdentifiers = identifiers.filter { photo.acceptedIdentifiers.contains($0) }
        imageWasAccepted = (matchedIdentifiers.count > 0)
        
        if imageWasAccepted {
            label.text = "Great photo! Your collection has been updated."
        } else {
            label.text = "This photo does not appear to be \(photo.indefiniteArticleOverride ?? photo.indefiniteArticle)\(photo.name). Please try again."
        }
        
        recaptureButton.isHidden = imageWasAccepted ? true : false
        cancelButton.isHidden = imageWasAccepted ? true : false
        doneButton.isHidden = imageWasAccepted ? false : true
        activitySpinner.stopAnimating()
        UINotificationFeedbackGenerator().notificationOccurred(imageWasAccepted ? .success : .error)
    }
    
    func developerDisplayReturnedIdentifiers(_ identifiers: [String]) {
        let alert = UIAlertController(title: "Identifiers", message: identifiers.joined(separator: ", "), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
}
