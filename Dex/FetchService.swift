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
    
    // Public single-item fetch by numeric id
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let url = baseURL.appendingPathComponent("\(id)")
        return try await fetchPokemon(from: url)
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
    
    private func havePokemon() -> Bool {
        let key = "com.dex.haveSeededPokemon"
        let alreadyFetched = UserDefaults.standard.bool(forKey: key)
        return alreadyFetched
    }
}
