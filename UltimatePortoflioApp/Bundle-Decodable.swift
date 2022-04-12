//
//  Bundle-Decodable.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 08/04/2022.
//
// swiftlint:disable trailing_whitespace

import Foundation

extension Bundle {
    func decode<T: Decodable>(
        _ type: T.Type,
        from file: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        // <T: Decodable> : We don't know what type of data we will decode.
        // It could be a String, an Array of Strings, etc. We are making it flexible.
        // We are saying "This decode method will work with some kind of placeholder called 'T' ".
        // We dont want to write our own awards, we want only to read them from JSON file. Thats why T must conform to Decodable
        // type: T.Type - it means that we want to cover the type of the T, not the instance of that type.
        // If f.e. JSON file would contain only one thing: number 5, we would pass in the Int.self, as a Int Type, not an instance of Int.
        // We want to pass a type of which the data we want to decode to
        // DateDecodingStrategy - default type of decoding date from JSON. We can modify it later.
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value - \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle due to corrupted JSON file")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
