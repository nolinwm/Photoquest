//
//  PhotoquestTests.swift
//  PhotoquestTests
//
//  Created by Nolin McFarland on 4/29/22.
//

import XCTest
@testable import Photoquest

class PhotoquestTests: XCTestCase {

    override func setUpWithError() throws {
//        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
//        try super.tearDownWithError()
    }
    
    func testIndefiniteArticleRules() {
        let aPhoto = Photo(id: "0", name: "Strawberry", acceptedIdentifiers: [])
        let anPhoto = Photo(id: "1", name: "Orange", acceptedIdentifiers: [])
        let pluralPhoto = Photo(id: "2", name: "Grapes", acceptedIdentifiers: [])
        let overridePhoto = Photo(id: "3", name: "Cheese", acceptedIdentifiers: [], indefiniteArticleOverride: "")
        XCTAssert(aPhoto.indefiniteArticle == "a ", "\(aPhoto.name) returned incorrect indefinite article: \(aPhoto.indefiniteArticle)")
        XCTAssert(anPhoto.indefiniteArticle == "an ", "\(anPhoto.name) returned incorrect indefinite article: \(anPhoto.indefiniteArticle)")
        XCTAssert(pluralPhoto.indefiniteArticle == "", "\(pluralPhoto.name) returned incorrect indefinite article: \(pluralPhoto.indefiniteArticle)")
        XCTAssert(overridePhoto.indefiniteArticle == "", "\(overridePhoto.name) returned incorrect indefinite article: \(overridePhoto.indefiniteArticle)")
    }
}
