//
//  PokemonViewModel.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 29.11.2024.
//

import Foundation
import CoreData

@MainActor
class PokemonViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    @Published private(set) var status = Status.notStarted
    
    private let controller: FetchService
    private let context = PersistenceController.shared.container.viewContext
    
    init(controller: FetchService) {
        self.controller = controller
    }
    
    func getPokemon() async {
        status = .fetching
        
        do {
            // Try to fetch from the API
            guard let pokedex = try await controller.fetchAllPokemon() else {
                print("Pokémon have already been fetched")
                status = .success
                return
            }
            
            // Insert all fetched Pokémon into Core Data
            for pokemon in pokedex {
                let newPokemon = Pokemon(context: context)
                
                newPokemon.id = Int16(pokemon.id)
                newPokemon.name = pokemon.name
                newPokemon.types = pokemon.types.map(\.self)
                newPokemon.organizeTypes()
                
                newPokemon.hp = Int16(pokemon.hp)
                newPokemon.attack = Int16(pokemon.attack)
                newPokemon.defense = Int16(pokemon.defense)
                newPokemon.specialAttack = Int16(pokemon.specialAttack)
                newPokemon.specialDefense = Int16(pokemon.specialDefense)
                newPokemon.speed = Int16(pokemon.speed)
                newPokemon.spriteURL = pokemon.spriteURL
                newPokemon.shinyURL = pokemon.shinyURL
                
                newPokemon.favorite = false
                newPokemon.spritesDownloaded = false
            }
            
            try context.save()
            
            // Download sprites for these new Pokémon
            await storeSprites(for: pokedex.map(\.id))
            
            status = .success
            
        } catch {
            print("❌ Fetch failed: \(error)")
            status = .failed(error: error)
        }
    }
    
    // MARK: - Store Sprite Data for Newly Added Pokémon
    private func storeSprites(for ids: [Int]) async {
        let request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@ AND spritesDownloaded == %d", ids, false)
        
        do {
            let newPokemon = try context.fetch(request)
            
            for pokemon in newPokemon {
                guard let spriteURL = pokemon.spriteURL,
                      let shinyURL = pokemon.shinyURL else { continue }
                
                do {
                    let (spriteData, _) = try await URLSession.shared.data(from: spriteURL)
                    let (shinyData, _) = try await URLSession.shared.data(from: shinyURL)
                    
                    pokemon.sprite = spriteData
                    pokemon.shiny = shinyData
                    pokemon.spritesDownloaded = true
                    
                } catch {
                    print("⚠️ Sprite fetch failed for \(pokemon.name ?? "unknown"): \(error)")
                }
            }
            
            try context.save()
            print("✅ Stored sprites for \(newPokemon.count) Pokémon")
            
        } catch {
            print("❌ Core Data fetch error: \(error)")
        }
    }
}
