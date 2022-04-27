//
//  LandingViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit
class LandingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInWithAppleTapped(_ sender: Any) {
        let mainTabViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "rootTabViewController")
        view.window?.rootViewController = mainTabViewController
        view.window?.makeKeyAndVisible()
    }
}
