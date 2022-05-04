//
//  Photo.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import Foundation
import UIKit
import MapKit

struct Photo {
    let id: String
    let name: String
    let acceptedIdentifiers: [String]
    var imageUrl: String?
    var image: UIImage?
    var capturedDate: Date?
    var coordinate: CLLocationCoordinate2D?
    
    /*
     Determines indefinite article using the following rules:
        - If the name ends in an s, return ""
        - If the name starts a vowel, return "an "
        - If the name starts with a consonant, return "a "
     
     If these rules don't apply to the name of the photo, provide the correct indefinite article in the indefiniteArticleOverride variable.
     */
    var indefiniteArticle: String {
        if let override = indefiniteArticleOverride { return override }
        let lowercased = name.lowercased()
        if lowercased.hasSuffix("s") { return ""}
        if ("aeiou").contains(lowercased.prefix(1)) { return "an " }
        return "a "
    }
    let indefiniteArticleOverride: String?
    
    init(id: String, name: String, acceptedIdentifiers: [String], imageUrl: String? = nil, image: UIImage? = nil, capturedDate: Date? = nil, coordinate: CLLocationCoordinate2D? = nil, indefiniteArticleOverride: String? = nil) {
        self.id = id
        self.name = name
        self.acceptedIdentifiers = acceptedIdentifiers
        self.imageUrl = imageUrl
        self.image = image
        self.capturedDate = capturedDate
        self.coordinate = coordinate
        self.indefiniteArticleOverride = indefiniteArticleOverride
    }
}
