//
//  Quest.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import Foundation

struct Quest {
    let id: String
    let name: String
    var photos: [Photo]
    var capturedPhotos: [Photo] {
        return photos.filter {
            $0.image != nil && $0.capturedDate != nil
        }
    }
}
