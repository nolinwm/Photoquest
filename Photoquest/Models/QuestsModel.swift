//
//  QuestsModel.swift
//  Photoquest
//
//  Created by Nolin McFarland on 5/3/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation
import UIKit

protocol QuestsModelDelegate {
    func receivedQuests(quests: [Quest])
}

struct QuestsModel {
    
    private let firestore = Firestore.firestore()
    var delegate: QuestsModelDelegate?
    
    func fetchQuests() {
        firestore.collection("quests").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                // TODO: Fetch quests error handling
                return
            }
            var fetchedQuests = [Quest]()
            for doc in snapshot.documents {
                let name = doc["name"] as! String
                let photoCount = doc["photoCount"] as! Int
                fetchCapturedPhotoCount(for: doc.documentID) { capturedPhotoCount in
                    let quest = Quest(id: doc.documentID, name: name, photoCount: photoCount, capturedPhotoCount: capturedPhotoCount)
                    fetchedQuests.append(quest)
                    if fetchedQuests.count == snapshot.documents.count {
                        delegate?.receivedQuests(quests: fetchedQuests)
                    }
                }
            }
        }
    }
    
    private func fetchCapturedPhotoCount(for questId: String, completion: @escaping (Int) -> Void) {
        firestore.collection("userCapturedPhotoCountData")
            .whereField("questId", isEqualTo: questId)
            .whereField("userId", isEqualTo: AuthService.shared.signedInUid ?? "").getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    // TODO: Fetch captured photo count error handling
                    return
                }
                if snapshot.documents.count >= 1 {
                    let capturedPhotoCount = snapshot.documents.first!["capturedPhotoCount"] as! Int
                    completion(capturedPhotoCount)
                } else {
                    // Create doc if not found
                    let newDoc = firestore.collection("userCapturedPhotoCountData").document(UUID().uuidString)
                    newDoc.setData([
                        "capturedPhotoCount": 0,
                        "questId": questId,
                        "userId": AuthService.shared.signedInUid ?? ""
                    ])
                    completion(0)
                }
            }
    }
}
