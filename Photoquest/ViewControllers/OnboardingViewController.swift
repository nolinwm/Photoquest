//
//  OnboardingViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        view.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main) .instantiateViewController(withIdentifier: "rootTabViewController")
        view.window?.makeKeyAndVisible()
    }
}
