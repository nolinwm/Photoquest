//
//  TestData.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import Foundation
import UIKit
import CoreLocation

struct TestData {
    static let bananaPhoto = Photo(id: "0", name: "Banana", acceptedIdentifiers: ["banana", "bananas"], image: nil, capturedDate: nil, coordinate: nil)
    static let applePhoto = Photo(id: "1", name: "Apple", acceptedIdentifiers: ["apple","apples"], image: nil, capturedDate: nil, coordinate: nil)
    static let strawberryPhoto = Photo(id: "2", name: "Strawberry", acceptedIdentifiers: ["strawberry","strawberries"], image: UIImage(named: "strawberry"), capturedDate: Date.now - 86_400, coordinate: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458))
    
    static let fruitQuest = Quest(id: "3", name: "Fruit", photoCount: 3, capturedPhotoCount: 1)
    
    static let quests = [fruitQuest]
}
