//
//  AuthService.swift
//  Photoquest
//
//  Created by Nolin McFarland on 5/2/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    var signedInUid: String? {
        return auth.currentUser?.uid
    }
    
    func createUser(emailAddress: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: emailAddress, password: password) { result, error in
            guard let result = result, error == nil else {
                completion(error)
                return
            }
            
            // Create firestore entry for user
            firestore.collection("users").document(result.user.uid).setData([
                "id": result.user.uid,
                "emailAddress": emailAddress
            ])
            
            completion(nil)
        }
    }
    
    func signIn(emailAddress: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: emailAddress, password: password) { result, error in
            completion(error)
        }
    }
    
    func signOut() {
        try? auth.signOut()
        // TODO: Sign out error handling
    }
    
    // Calls a completion closure with a Bool representing if the password-sign-in-method account exists
    func accountExists(with emailAddress: String, completion: @escaping(Bool) -> Void) {
        auth.fetchSignInMethods(forEmail: emailAddress) { methods, error in
            guard error == nil else {
                completion(true)
                // TODO: Fetch sign in methods error handling
                return
            }
            guard let methods = methods else {
                completion(false)
                return
            }
            let exists = methods.contains("password")
            completion(exists)
        }
    }
}
