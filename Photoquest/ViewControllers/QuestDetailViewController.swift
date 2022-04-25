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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeView()
        setupSwipeGestures()
        resetImagePopAnimation()
    }
    
    private func stylizeView() {
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
}

// MARK: - Image Pop Animation Methods
extension QuestDetailViewController {
    
    private func animateImagePop(direction: UISwipeGestureRecognizer.Direction, duration: Double) {
        let directionModifier: CGFloat = (direction == .left) ? -1 : 1
        animationStarted()
        
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
            self.animationFinished()
        }
    }
    
    private func resetImagePopAnimation() {
        frontImageView.transform = .identity
        middleImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        backImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    private func animationStarted() {
        cameraButton.isEnabled = false
        imageLabel.alpha = .zero
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func animationFinished() {
        cameraButton.isEnabled = true
        imageLabel.alpha = 1
        
        /*
         TODO: Update image view images to match new stack order
         frontImageView to first in stack
         middleImageView to second in stack
         backImageView to first in stack
        */
        
        resetImagePopAnimation()
    }
}
