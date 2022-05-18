//
//  MapAnnotationViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/29/22.
//

import UIKit

class MapAnnotationViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var capturedDateLabel: UILabel!
    @IBOutlet weak var dimView: UIView!
    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        stackView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissWithAnimation)))
        
        if let photo = photo {
            imageView.image = photo.image
            photoLabel.text = photo.name
            if let capturedDate = photo.capturedDate {
                capturedDateLabel.text = "Captured \(capturedDate.formatted(date: .long, time: .omitted))"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 0.35
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5, options: .curveEaseInOut) {
            self.stackView.transform = .identity
        }
    }
    
    @objc func dismissWithAnimation() {
        UIView.animate(withDuration: 0.25) {
            self.dimView.alpha = 0
        }
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.stackView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        } completion: { complete in
            self.dismiss(animated: false)
        }
    }
}
