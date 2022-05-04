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
                        coordinate = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
                    }
                    completion(imageUrl, capturedDate, coordinate)
                } else {
                    completion(nil, nil, nil)
                }
            }
    }
    
    func savePhoto(_ photo: Photo) {
        guard let image = photo.image else { return }
        uploadImage(image) { imageUrl in
            firestore.collection("userPhotoData")
                .whereField("photoId", isEqualTo: photo.id)
                .whereField("userId", isEqualTo: AuthService.shared.signedInUid ?? "")
                .getDocuments { snapshot, error in
                    guard let snapshot = snapshot, error == nil else {
                        // TODO: Save photo error handling
                        return
                    }
                    if snapshot.documents.count >= 1 {
                        // Photo exists, update data
                        let doc = snapshot.documents.first!
                        doc.reference.updateData([
                            "imageUrl": imageUrl,
                            "capturedTimestamp": Timestamp(date: photo.capturedDate!),
                        ])
                        if let coordinate = photo.coordinate {
                            doc.reference.updateData([
                                "geopoint": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            ])
                        }
                    } else {
                        // New photo, set data and update capturedPhotoCount
                        let newDoc = firestore.collection("userPhotoData").document()
                        newDoc.setData([
                            "photoId": photo.id,
                            "userId": AuthService.shared.signedInUid ?? "",
                            "imageUrl": imageUrl,
                            "capturedTimestamp": Timestamp(date: photo.capturedDate!),
                        ])
                        if let coordinate = photo.coordinate {
                            newDoc.updateData([
                                "geopoint": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            ])
                        }
                    }
                }
        }
    }
    
    // Upload an image to firebase storage and call a completion handler with the download URL
    private func uploadImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        let reference = storage.reference().child("images/\(UUID().uuidString).jpeg")
        let data = image.jpegData(compressionQuality: 0.5)
        guard let data = data else { return }
        
        reference.putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                // TODO: Image upload error handling
                return
            }
            reference.downloadURL { url, error in
                guard let url = url, error == nil else {
                    // TODO: Download url error handling
                    return
                }
                completion(url.absoluteString)
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
