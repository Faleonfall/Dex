//
//  FetchService.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 28.11.2024.
//

import Foundation
import CoreData

struct FetchService {
    enum FetchError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchAllPokemon() async throws -> [FetchedPokemon]? {
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [FetchedPokemon] = []
        
        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "5")]
        
        guard let fetchURL = fetchComponents?.url else {
            throw FetchError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw FetchError.badData
        }
        
        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }
        
        return allPokemon
    }
    
    private func fetchPokemon(from url: URL) async throws -> FetchedPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        
        let pokemon = try decoder.decode(FetchedPokemon.self, from: data)
        
        print("Fetched \(pokemon.id): \(pokemon.name)")
        
        return pokemon
    }
    
    private func havePokemon () -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            
            if checkPokemon.count == 2 {
                return true
            }
        } catch {
            print("Fetch failed: \(error)")
            return false
        }
        
        return false
    }
}
