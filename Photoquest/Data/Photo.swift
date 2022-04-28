//
//  Photo.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import Foundation
import UIKit

struct Photo {
    let name: String
    let acceptedIdentifiers: [String]
    var image: UIImage?
    var capturedDate: Date?
    
    /*
     Determines indefinite article using the following rules:
        - If the name ends in an s, return ""
        - If the name starts a vowel, return "an "
        - If the name starts with a consonant, return "a "
     
     If these rules don't apply to the name of the photo, provide the correct indefinite article in the indefiniteArticleOverride variable.
     */
    var indefiniteArticle: String {
        let lowercased = name.lowercased()
        if lowercased.hasSuffix("s") { return ""}
        if ("aeiou").contains(lowercased.prefix(1)) { return "an " }
        return "a "
    }
    let indefiniteArticleOverride: String? = nil
}
