//
//  ProfileViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        AuthService.shared.signOut()
        view.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "landingViewController")
        view.window?.makeKeyAndVisible()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
