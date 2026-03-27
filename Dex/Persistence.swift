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
    
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(previewPokemon)
        return container
    }()
}
