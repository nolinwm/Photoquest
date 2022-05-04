//
//  ViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/24/22.
//

import UIKit
import CoreML
import Vision
import CoreLocation

class QuestDetailViewController: UIViewController, PhotoModelDelegate {
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var overImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var infoStack: UIStackView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var capturedLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var questCell: QuestTableViewCell?
    
    let imagePicker = UIImagePickerController()
    let imagePlaceholder = UIImage(named: "imagePlaceholder")
    var capturedImage: UIImage?
    
    var photoModel = PhotoModel()
    var quest: Quest?
    var photos = [Photo]()
    var photoIndex = 0
    
    let locationManager = CLLocationManager()
    var photoIndexToTagLocation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNetworkLoading(true)
        
        photoModel.delegate = self
        if let quest = quest {
            photoModel.fetchPhotos(for: quest.id)
        }
        
        locationManager.delegate = self
        stylizeView()
    }
    
    private func stylizeView() {
        navigationItem.title = quest?.name
        backImageView.layer.cornerRadius = 20
        middleImageView.layer.cornerRadius = 20
        frontImageView.layer.cornerRadius = 20
        overImageView.layer.cornerRadius = 20
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
        switch sender.direction {
        case .left:
            presentNextPhoto()
        case .right:
            presentPreviousPhoto()
        default:
            break
        }
    }
    
    @IBAction func pageControlTapped(_ sender: Any) {
        presentNextPhoto(setIndexTo: pageControl.currentPage)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let irVC = segue.destination as? ImageRecognitionViewController {
            irVC.photo = photos[photoIndex]
            irVC.capturedImage = capturedImage
            irVC.delegate = self
        } else if let mapVC = segue.destination as? QuestMapViewController {
            mapVC.photos = photos
            mapVC.initialPhotoIndex = photoIndex
        }
    }
    
    func setNetworkLoading(_ loading: Bool) {
        if loading {
            activitySpinner.startAnimating()
        } else {
            activitySpinner.stopAnimating()
        }
        
        UIView.animate(withDuration: (loading ? 0 : 0.25), delay: 0, options: .curveEaseIn) {
            self.infoStack.alpha = loading ? 0 : 1
            self.pageControl.alpha = loading ? 0 : 1
        } completion: { complete in
            self.cameraButton.isEnabled = loading ? false : true
        }
        
        UIView.animate(withDuration: (loading ? 0 : 0.25), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .curveEaseOut) {
            self.infoStack.transform = loading ? CGAffineTransform(scaleX: 0.8, y: 0.8) : .identity
            self.pageControl.transform = loading ? CGAffineTransform(scaleX: 0.8, y: 0.8) : .identity
        }
    }
    
    func receivedPhotos(photos: [Photo]) {
        self.photos = photos
        fetchImages()
        setupImagePicker()
        setupSwipeGestures()
        setupImageViews()
        setNetworkLoading(false)
    }
}

// MARK: - Animation Methods
extension QuestDetailViewController {
    
    func fetchImages() {
        for index in 0..<photos.count {
            guard let imageUrl = photos[index].imageUrl else { continue }
            photoModel.fetchImage(for: imageUrl) { image in
                self.photos[index].image = image
                if index == self.photoIndex {
                    self.frontImageView.image = image
                }
            }
        }
    }
    
    func setupImageViews() {
        pageControl.numberOfPages = photos.count
        adjustPhotoIndex(to: photoIndex) // Ensures photoIndex is in bounds
        resetAnimationState()
        imageLabel.text = photos[photoIndex].name
        if let capturedDate = photos[photoIndex].capturedDate {
            capturedLabel.text = "Captured \(capturedDate.formatted(date: .long, time: .omitted))"
        } else {
            capturedLabel.text = "Not Captured"
        }
    }
    
    func presentNextPhoto(setIndexTo: Int? = nil) {
        setActionLoading(true)
        backImageView.image = photos[photoIndex].image ?? imagePlaceholder
        if let setIndexTo = setIndexTo {
            adjustPhotoIndex(to: setIndexTo)
        } else {
            adjustPhotoIndex(by: 1)
        }
        middleImageView.image = photos[photoIndex].image ?? imagePlaceholder
        
        animateNextPhotoPresentation(duration: 0.425) { complete in
            self.frontImageView.image = self.photos[self.photoIndex].image ?? self.imagePlaceholder
            self.resetAnimationState()
            self.setActionLoading(false)
        }
    }
    
    func presentPreviousPhoto() {
        setActionLoading(true)
        adjustPhotoIndex(by: -1)
        backImageView.image = photos[photoIndex].image ?? imagePlaceholder
        overImageView.image = photos[photoIndex].image ?? imagePlaceholder
        
        animatePreviousPhotoPresentation(duration: 0.425) { complete in
            self.frontImageView.image = self.photos[self.photoIndex].image ?? self.imagePlaceholder
            self.resetAnimationState()
            self.setActionLoading(false)
        }
    }
    
    func resetAnimationState() {
        frontImageView.transform = .identity
        middleImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        overImageView.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
    }
    
    func animateAndUpdateLabels(duration: Double) {
        // Slide infoStack down
        UIView.animate(withDuration: duration * 0.25, delay: 0, options: .curveEaseIn) {
            self.infoStack.transform = CGAffineTransform(translationX: 0, y: 200)
        } completion: { complete in
            self.imageLabel.text = self.photos[self.photoIndex].name
            if let capturedDate = self.photos[self.photoIndex].capturedDate {
                self.capturedLabel.text = "Captured \(capturedDate.formatted(date: .long, time: .omitted))"
            } else {
                self.capturedLabel.text = "Not Captured"
            }
        }
        
        // Slide infoStack back to original position
        UIView.animate(withDuration: duration * 0.6, delay: duration * 0.4, usingSpringWithDamping: 0.75, initialSpringVelocity: 4, options: .curveEaseOut) {
            self.infoStack.transform = .identity
        }
    }
    
    func animateNextPhotoPresentation(duration: Double, completionHandler: @escaping (_ complete: Bool) -> Void) {
        
        animateAndUpdateLabels(duration: duration)
        
        // Move backImageView off screen to the left
        backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            .concatenating(
                CGAffineTransform(translationX: -view.frame.width, y: 0)
            )
        
        // Slide backImageView to center of screen
        UIView.animate(withDuration: duration * 0.75, delay: duration * 0.25) {
            self.backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        // Scale middleImageView up to full size
        UIView.animate(withDuration: duration * 0.75, delay: duration * 0.1) {
            self.middleImageView.transform = .identity
        }
        
        /*
         Slide and rotate frontImageView off screen in direction of swipe
         Call completionHandler on completion as this animation takes the full duration
        */
        let frontTranslation = CGPoint(
            x: view.frame.width * -2,
            y: view.frame.height
        )
        UIView.animate(withDuration: duration, delay: 0) {
            self.frontImageView.transform = CGAffineTransform(rotationAngle: .pi / -3)
                .concatenating(
                    CGAffineTransform(translationX: frontTranslation.x, y: frontTranslation.y)
                )
        } completion: { complete in
            completionHandler(complete)
        }
    }
    
    func animatePreviousPhotoPresentation(duration: Double, completionHandler: @escaping (_ complete: Bool) -> Void) {
        
        animateAndUpdateLabels(duration: duration)
        
        // Move overImageView off screen to the right and slightly down
        overImageView.transform = CGAffineTransform(translationX: view.frame.width * 2, y: 50)
        
        // Scale front and middleImageView's down
        UIView.animate(withDuration: duration * 0.35, delay: duration * 0.35) {
            self.frontImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.middleImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        // Slide backImageView off screen to the right
        UIView.animate(withDuration: duration * 0.5, delay: 0) {
            self.backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                .concatenating(
                    CGAffineTransform(translationX: self.view.frame.width * 2, y: 0)
                )
                .concatenating(
                    CGAffineTransform(rotationAngle: .pi / 8)
                )
        }
        
        /*
         Slide overImageView to center of screen
         Call completionHandler on completion as this animation takes the full duration
         */
        UIView.animate(withDuration: duration * 0.65, delay: duration * 0.35) {
            self.overImageView.transform = .identity
        } completion: { complete in
            completionHandler(complete)
        }
    }
    
    private func setActionLoading(_ loading: Bool) {
        if loading {
            cameraButton.isEnabled = false
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            cameraButton.isEnabled = true
        }
    }
    
    func adjustPhotoIndex(by increment: Int? = nil, to hardValue: Int? = nil) {
        photoIndex = hardValue ?? photoIndex + (increment ?? 1)
        if photoIndex < 0 {
            photoIndex = photos.count - 1
        } else if photoIndex >= photos.count {
            photoIndex = 0
        }
        pageControl.currentPage = photoIndex
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
            DispatchQueue.main.async {
                self.frontImageView.image = capturedImage
            }
            photos[photoIndex].image = capturedImage
            photos[photoIndex].capturedDate = Date.now
            photoModel.savePhoto(photos[photoIndex], questId: quest?.id ?? "") { isNewPhoto in
                if isNewPhoto {
                    self.questCell?.incrementPhotoCount()
                }
            }
            tagPhotoLocation()
        }
    }
}

// MARK: - CoreLocation Methods
extension QuestDetailViewController: CLLocationManagerDelegate {
    
    func tagPhotoLocation() {
        photoIndexToTagLocation = photoIndex
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            photos[photoIndexToTagLocation].coordinate = location.coordinate
//            photoModel.savePhoto(photos[photoIndex], questId: quest?.id ?? "")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Location Manager Error Handling
        print(error.localizedDescription)
    }
}
