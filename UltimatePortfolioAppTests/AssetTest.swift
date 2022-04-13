//
//  AssetTest.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 12/04/2022.
//

import XCTest
@testable import UltimatePortfolioApp

/// Testing asset catalog. Any method that starts with 'test'
/// takes no parameters and returns Void
/// will be treated as a test method by Swift
class AssetTest: XCTestCase {
    
    /// Ensuring that all color from Asset Catalog that we expect to be there, are there
    ///
    /// Loading color strings into a SwiftUI Color Struct will always succeed. If the color name is just missing it will still work and you will get an error log in the debug output which isn't very useful. We cannot test that, becuase it'll always work. Instead, we want to load color using UIKit, because UIColor(named: ) will turn the optional UIColor which can be veryfied if it contain a value or not (seeing if it passed or failed).
    func testColorsExist() {
        for color in Project.colors {
            /// We want to be sure that value behind that 'color' String is not nil.
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }
    
    /// Checking if JSON file from bundle is loading correctly into allAward array.
    func testJSONLoadsCorrectly() {
        XCTAssertFalse(Award.allAwards.isEmpty, "Failed to load awards from JSON.")
    }
}
