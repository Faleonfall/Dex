//
//  Persistence.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftData
import Foundation

@MainActor
struct PersistenceController {
    // Decode once so the same instance can be inserted and used in previews
    static let previewPokemon: Pokemon = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let url = Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!
        let pokemonData = try! Data(contentsOf: url)
        return try! decoder.decode(Pokemon.self, from: pokemonData)
    }()
    
    // Sample preview database
    static let preview: ModelContainer = {
        let container = try! ModelContainer(
            for: Pokemon.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        container.mainContext.insert(previewPokemon)
        return container
    }()
}
