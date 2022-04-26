//
//  ViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/24/22.
//

import UIKit
import CoreML
import Vision

class QuestDetailViewController: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imageLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var capturedImage: UIImage?
    
    var quest: Quest?
    var photoIndex = -1 // Starts at -1 and increments to 0 in viewDidLoad's imagePopAnimationFinished() call
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeView()
        setupImagePicker()
        setupSwipeGestures()
        imagePopAnimationFinished() // Call on load to prepare for next animation
    }
    
    private func stylizeView() {
        navigationItem.title = quest?.name
        backImageView.layer.cornerRadius = 20
        middleImageView.layer.cornerRadius = 20
        frontImageView.layer.cornerRadius = 20
    }
    
    private func setupSwipeGestures() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        leftSwipeGestureRecognizer.direction = .left
        frontImageView.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipeGestureRecognizer.direction = .right
        frontImageView.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        animateImagePop(direction: sender.direction, duration: 0.425)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ImageRecognitionViewController {
            vc.photo = quest?.photos[photoIndex]
            vc.capturedImage = self.capturedImage
            vc.delegate = self
        }
    }
}

// MARK: - Image Pop Animation Methods
extension QuestDetailViewController {
    
    private func animateImagePop(direction: UISwipeGestureRecognizer.Direction, duration: Double) {
        let directionModifier: CGFloat = (direction == .left) ? -1 : 1
        imagePopAnimationStarted()
        
        // Move backImageView off screen in direction of swipe
        backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            .concatenating(
                CGAffineTransform(translationX: view.frame.width * directionModifier, y: 0)
            )
        
        // Scale middleImageView up to full size
        UIView.animate(withDuration: duration * 0.75, delay: duration * 0.1) {
            self.middleImageView.transform = .identity
        }
        
        // Slide backImageView to center of screen
        UIView.animate(withDuration: duration * 0.75, delay: duration * 0.25) {
            self.backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        /*
         Slide and rotate frontImageView off screen in direction of swipe
         Call animationFinished on completion as this animation takes the full duration
        */
        let frontTranslation = CGPoint(
            x: view.frame.width * 2 * directionModifier,
            y: view.frame.height
        )
        let frontRotation: CGFloat = .pi / 3 * directionModifier
        UIView.animate(withDuration: duration, delay: 0) {
            self.frontImageView.transform = CGAffineTransform(rotationAngle: frontRotation)
                .concatenating(
                    CGAffineTransform(translationX: frontTranslation.x, y: frontTranslation.y)
                )
        } completion: { complete in
            self.imagePopAnimationFinished()
        }
    }
    
    private func resetImagePopAnimation() {
        frontImageView.transform = .identity
        middleImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    private func imagePopAnimationStarted() {
        cameraButton.isEnabled = false
        imageLabel.alpha = .zero
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func imagePopAnimationFinished() {
        guard let quest = quest else { return }
        
        photoIndex += 1
        if quest.photos.count <= photoIndex {
            photoIndex = 0
        }
        
        var nextPhotoIndex = photoIndex + 1
        if quest.photos.count <= nextPhotoIndex {
            nextPhotoIndex = 0
        }
        
        DispatchQueue.main.async {
            self.imageLabel.text = quest.photos[self.photoIndex].name
            self.frontImageView.image = quest.photos[self.photoIndex].image ?? UIImage(named: "imagePlaceholder")
            self.middleImageView.image = quest.photos[nextPhotoIndex].image ?? UIImage(named: "imagePlaceholder")
            self.backImageView.image = self.frontImageView.image
            self.cameraButton.isEnabled = true
            self.imageLabel.alpha = 1
            self.resetImagePopAnimation()
        }
    }
}

// MARK: - UIImagePickerController Methods
extension QuestDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        capturedImage = info[.originalImage] as? UIImage
        picker.dismiss(animated: true)
        performSegue(withIdentifier: "segueToImageRecognition", sender: self)
    }
}

// MARK: - ImageRecognitionViewControllerDelegate Methods
extension QuestDetailViewController: ImageRecognitionViewControllerDelegate {
    
    func imageRecognitionViewControllerDidDismiss(imageWasAccepted: Bool, recaptureRequested: Bool) {
        if recaptureRequested {
            present(imagePicker, animated: true)
            return
        }
        if imageWasAccepted, let capturedImage = capturedImage {
            quest?.photos[photoIndex].image = capturedImage
            quest?.photos[photoIndex].capturedDate = Date.now
            frontImageView.image = capturedImage
            backImageView.image = frontImageView.image
        }
    }
}
