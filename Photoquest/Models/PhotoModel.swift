//
//  PhotoModel.swift
//  Photoquest
//
//  Created by Nolin McFarland on 5/3/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import UIKit

protocol PhotoModelDelegate {
    func receivedPhotos(photos: [Photo])
}

struct PhotoModel {
    
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    var delegate: PhotoModelDelegate?
    
    func fetchPhotos(for questId: String) {
        firestore.collection("photos").whereField("questId", isEqualTo: questId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                // TODO: Fetch photos error handling
                return
            }
            var photos = [Photo]()
            for doc in snapshot.documents {
                let name = doc["name"] as! String
                let acceptedIdentifiersString = doc["acceptedIdentifiers"] as! String
                let acceptedIdentifiers = acceptedIdentifiersString.components(separatedBy: ", ")
                
                fetchUserPhotoData(for: doc.documentID) { imageUrl, capturedDate, coordinate in
                    let photo = Photo(id: doc.documentID, name: name, acceptedIdentifiers: acceptedIdentifiers, image: nil, capturedDate: capturedDate, coordinate: coordinate, indefiniteArticleOverride: nil)
                    photos.append(photo)
                    if photos.count == snapshot.documents.count {
                        delegate?.receivedPhotos(photos: photos)
                    }
                }
            }
        }
    }
    
    private func fetchUserPhotoData(for photoId: String, completion: @escaping (String?, Date?, CLLocationCoordinate2D?) -> Void) {
        firestore.collection("userPhotoData")
            .whereField("photoId", isEqualTo: photoId)
            .whereField("userId", isEqualTo: AuthService.shared.signedInUid ?? "")
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    // TODO: Fetch user photo data error handling
                    return
                }
                if snapshot.documents.count >= 1 {
                    let doc = snapshot.documents.first!
                    let imageUrl = doc["imageUrl"] as? String
                    
                    let timestamp = doc["capturedTimestamp"] as? Timestamp
                    let capturedDate = timestamp?.dateValue()
                    
                    let geopoint = doc["geopoint"] as? GeoPoint
                    var coordinate: CLLocationCoordinate2D?
                    if let geopoint = geopoint {
                        if geopoint.latitude != 0 && geopoint.longitude != 0 {
                            coordinate = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                        }
                    }
                    completion(imageUrl, capturedDate, coordinate)
                } else {
                    completion(nil, nil, nil)
                }
            }
    }
    
    func fetchImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        let reference = storage.reference(forURL: url)
        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
    }
}
