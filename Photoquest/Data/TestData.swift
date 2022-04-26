//
//  TestData.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import Foundation
import UIKit

struct TestData {
    static let bananaPhoto = Photo(name: "Banana", acceptedIdentifiers: ["banana", "bananas"], image: nil, capturedDate: nil)
    static let applePhoto = Photo(name: "Apple", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    static let strawberryPhoto = Photo(name: "Strawberry", acceptedIdentifiers: [], image: UIImage(named: "strawberry"), capturedDate: Date.now - 86_400)
    static let orangePhoto = Photo(name: "Orange", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    static let grapesPhoto = Photo(name: "Grapes", acceptedIdentifiers: [], image: UIImage(named: "grapes"), capturedDate: Date.now)
    static let raspberryPhoto = Photo(name: "Raspberry", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    static let blackberryPhoto = Photo(name: "Blackberry", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    static let kiwiPhoto = Photo(name: "Kiwi", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    static let watermelonPhoto = Photo(name: "Watermelon", acceptedIdentifiers: [], image: UIImage(named: "watermelon"), capturedDate: Date.now - 864_000)
    static let pineapplePhoto = Photo(name: "Pineapple", acceptedIdentifiers: [], image: nil, capturedDate: nil)
    
    static let fruitQuest = Quest(name: "Fruit", photos: [bananaPhoto, applePhoto, strawberryPhoto, orangePhoto, grapesPhoto, raspberryPhoto, blackberryPhoto, kiwiPhoto, watermelonPhoto, pineapplePhoto])
    
    static let quests = [fruitQuest]
}
