//
//  PokemonViewModel.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 29.11.2024.
//

import Foundation

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
    
    init(controller: FetchService) {
        self.controller = controller
        
        Task {
            await getPokemon()
        }
    }
    
    func getPokemon() async {
        status = .fetching
        
        do {
            guard let pokedex = try await controller.fetchAllPokemon() else {
                print("Pokemon have already been fetched")
                status = .success
                return
            }
            
            for pokemon in pokedex {
                let newPokemon = Pokemon(context: PersistenceController.shared.container.viewContext)
                
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
                newPokemon.sprite = pokemon.sprite
                newPokemon.shiny = pokemon.shiny
                
                newPokemon.favorite = false
                
                try PersistenceController.shared.container.viewContext.save()
            }
            
            status = .success
            
        } catch {
            status = .failed(error: error)
        }
    }
}
