import Foundation
import SwiftData
import SwiftUI

@Model
class Pokemon: Decodable {
    @Attribute(.unique) var id: Int
    var attack: Int
    var defense: Int
    var favorite: Bool = false
    var hp: Int
    var name: String
    var shiny: Data?
    var shinyURL: URL
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    var sprite: Data?
    var spritesDownloaded: Bool = false
    var spriteURL: URL
    var types: [String]

    init(
        id: Int,
        attack: Int,
        defense: Int,
        favorite: Bool = false,
        hp: Int,
        name: String,
        shiny: Data? = nil,
        shinyURL: URL,
        specialAttack: Int,
        specialDefense: Int,
        speed: Int,
        sprite: Data? = nil,
        spritesDownloaded: Bool = false,
        spriteURL: URL,
        types: [String]
    ) {
        self.id = id
        self.attack = attack
        self.defense = defense
        self.favorite = favorite
        self.hp = hp
        self.name = name
        self.shiny = shiny
        self.shinyURL = shinyURL
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.sprite = sprite
        self.spritesDownloaded = spritesDownloaded
        self.spriteURL = spriteURL
        self.types = types
    }
    
    enum PokemonKeys: String, CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: String, CodingKey {
            case type
            
            enum TypeKeys: String, CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: String, CodingKey {
            case value = "base_stat"
            case stat
            
            enum StatKeys: String, CodingKey {
                case name
            }
        }
        
        enum SpriteKeys: String, CodingKey {
            case spriteURL = "front_default"
            case shinyURL = "front_shiny"
        }
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PokemonKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesContainer.isAtEnd {
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: PokemonKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: PokemonKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        var hp = 0
        var attack = 0
        var defense = 0
        var specialAttack = 0
        var specialDefense = 0
        var speed = 0
        
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: PokemonKeys.StatDictionaryKeys.self)
            let statContainer = try statsDictionaryContainer.nestedContainer(keyedBy: PokemonKeys.StatDictionaryKeys.StatKeys.self, forKey: .stat)
            switch try statContainer.decode(String.self, forKey: .name) {
            case "hp":
                hp = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "attack":
                attack = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "defense":
                defense = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "special-attack":
                specialAttack = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "special-defense":
                specialDefense = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "speed":
                speed = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            default:
                break
            }
        }
        
        let spriteContainer = try container.nestedContainer(keyedBy: PokemonKeys.SpriteKeys.self, forKey: .sprites)
        let spriteURL = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        let shinyURL = try spriteContainer.decode(URL.self, forKey: .shinyURL)
        
        self.id = id
        self.attack = attack
        self.defense = defense
        self.favorite = false
        self.hp = hp
        self.name = name
        self.shiny = nil
        self.shinyURL = shinyURL
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.sprite = nil
        self.spritesDownloaded = false
        self.spriteURL = spriteURL
        self.types = decodedTypes
    }
    
    var spriteImage: Image {
        if let data = sprite, let image = UIImage(data: data) {
            Image(uiImage: image)
        } else {
            Image(.bulbasaur)
        }
    }
    
    var shinyImage: Image {
        if let data = shiny, let image = UIImage(data: data) {
            Image(uiImage: image)
        } else {
            Image(.shinybulbasaur)
        }
    }
    
    var background: ImageResource {
        switch self.types[0] {
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
        default:
                .normalgrasselectricpoisonfairy
        }
    }
    
    var typeColor: Color {
        Color(types[0].capitalized)
    }
    
    var stats: [Stat] {
        [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defence", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
    
    func organizeTypes() {
        if self.types.count > 1 && self.types[0] == "normal" {
            self.types.swapAt(0, 1)
        }
    }
    
    struct Stat: Identifiable {
        let id: Int
        let name: String
        let value: Int
    }
}
