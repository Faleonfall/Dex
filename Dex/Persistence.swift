import SwiftData
import Foundation

@MainActor
struct PersistenceController {
    static let previewPokemon: Pokemon = {
        Pokemon(
            id: 1,
            attack: 49,
            defense: 49,
            hp: 45,
            name: "bulbasaur",
            shinyURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")!,
            specialAttack: 65,
            specialDefense: 65,
            speed: 45,
            spriteURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!,
            types: ["grass", "poison"]
        )
    }()

    static let previewPokemon2: Pokemon = {
        Pokemon(
            id: 2,
            attack: 62,
            defense: 63,
            hp: 60,
            name: "ivysaur",
            shinyURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/2.png")!,
            specialAttack: 80,
            specialDefense: 80,
            speed: 60,
            spriteURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!,
            types: ["grass", "poison"]
        )
    }()

    static let previewPokemon3: Pokemon = {
        Pokemon(
            id: 3,
            attack: 82,
            defense: 83,
            hp: 80,
            name: "venusaur",
            shinyURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/3.png")!,
            specialAttack: 100,
            specialDefense: 100,
            speed: 80,
            spriteURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!,
            types: ["grass", "poison"]
        )
    }()
    
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(previewPokemon)
        container.mainContext.insert(previewPokemon2)
        container.mainContext.insert(previewPokemon3)
        return container
    }()
}
