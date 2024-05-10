//
//  RecommendationPageTests.swift
//  CustomPlayerTests
//
//  Created by Blotenko on 10.05.2024.
//

import XCTest
import SwiftUI

@testable import CustomPlayer

class RecommendationPageTests: XCTestCase {
    
    func testRecommendationPage() {
        let songManager = SongManager.shared
        
        let contentView = RecommendationPage()
        
        let view = UIHostingController(rootView: contentView)
        
        view.loadView()

        XCTAssertEqual(songManager.recommendSongs()[0].title, "Song 1")
        XCTAssertEqual(songManager.recommendSongs()[1].title, "Song 2")
    }
}
