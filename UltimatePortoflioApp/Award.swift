//
//  Award.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 08/04/2022.
//
// swiftlint:disable trailing_whitespace

import Foundation

struct Award: Decodable, Identifiable {
    
    var id: String { name } // Identifier for struct will be its name
    let name: String
    let description: String
    let color: String
    let criterion: String
    let value: Int
    let image: String
    
    static let allAwards = Bundle.main.decode([Award].self, from: "Awards.json") // Decoding all awards from JSON file
    static let example = allAwards[0] // Example award
}
