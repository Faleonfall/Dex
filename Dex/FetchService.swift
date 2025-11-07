//
//  FetchService.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 28.11.2024.
//

import Foundation

struct FetchService {
    enum FetchError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchAllPokemon() async throws -> [Pokemon]? {
        // Temporary: since we're migrating to SwiftData, don't query local storage here.
        // You can replace this with a SwiftData-based check later.
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [Pokemon] = []
        
        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "151")]
        
        guard let fetchURL = fetchComponents?.url else {
            throw FetchError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw FetchError.badData
        }
        
        for pokemon in pokedex {
            if let urlString = pokemon["url"], let url = URL(string: urlString) {
                allPokemon.append(try await fetchPokemon(from: url))
            }
        }
        
        return allPokemon
    }
    
    private func fetchPokemon(from url: URL) async throws -> Pokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        print("Fetched \(pokemon.id): \(pokemon.name)")
        return pokemon
    }
    
    // MARK: - Temporary stub during migration to SwiftData
    // Replace with a SwiftData-based existence check later, e.g., using a ModelContext.
    private func havePokemon() -> Bool {
        // Option A: Always fetch (return false)
        // return false
        
        // Option B: Use a simple flag to avoid refetching repeatedly during dev
        let key = "com.dex.haveSeededPokemon"
        let alreadyFetched = UserDefaults.standard.bool(forKey: key)
        if alreadyFetched {
            return true
        } else {
            // Set to true only after you actually persist them (e.g., in your ViewModel after save)
            // For now, keep it false so fetch proceeds.
            return false
        }
    }
}
