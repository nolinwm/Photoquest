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
}
