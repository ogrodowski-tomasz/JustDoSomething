//
//  Award.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 08/04/2022.
//
// swiftlint:disable trailing_whitespace

import Foundation

/// A struct that manages Award type of data and decoding it from json file from decode
struct Award: Decodable, Identifiable {
    
    var id: String { name }
    let name: String
    let description: String
    let color: String
    let criterion: String
    let value: Int
    let image: String
    
    static let allAwards = Bundle.main.decode([Award].self, from: "Awards.json")
    // Example award
    static let example = allAwards[0]
}
