//
//  StringExtension.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/26/22.
//

import Foundation

extension String {
    
    // Vowel rule indefinite article. Return "an" if string starts with a vowel or "a" otherwise. 
    var indefiniteArticle: String {
        guard let first = self.first else { return "" }
        if ("aeiou").contains(first.lowercased()) {
            return "an"
        } else {
            return "a"
        }
    }
}
