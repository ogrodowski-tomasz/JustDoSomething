//
//  ExtensionTests.swift
//  UltimatePortfolioAppTests
//
//  Created by Tomasz Ogrodowski on 01/05/2022.
//

import XCTest
@testable import UltimatePortfolioApp
import SwiftUI

class ExtensionTests: XCTestCase {

    /// Checking if decoding from app bundle is being done correctly
    func testBundleDecodingawards() {
        let award = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(award.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    /// Checking if our function called 'decode' works with any type of data
    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(
            data,
            "There is no life, only Samsara.",
            "The string must match the content of DecodableString.json")
    }

    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "There should be 3 items decoded from DecodableDictionary.json")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain Int to String mapping.")
    }

    /// Checking the .onChange() extension. Does function inside the .onChange() is being called?
    func testBindingOnChange() {
        var onChangeFunctionRun = false

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        var storedValue = ""
        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )
        let changedBinding = binding.onChange(exampleFunctionToCall)
        changedBinding.wrappedValue = "Test"

        XCTAssertTrue(onChangeFunctionRun, "The onChange() function must be run when the binding is changed.")

    }
}
