//
//  OnboardingViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        view.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main) .instantiateViewController(withIdentifier: "rootTabViewController")
        view.window?.makeKeyAndVisible()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        if xOffset < view.bounds.width / 2 {
            if pageControl.currentPage == 1 {
                pageControl.currentPage = 0
            }
        } else {
            if pageControl.currentPage == 0 {
                pageControl.currentPage = 1
            }
        }
    }
}
