//
//  PokemonExt.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 29.11.2024.
//

import SwiftUI

extension Pokemon {
    var background: ImageResource {
        switch self.types![0] {
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
        Color(types![0].capitalized)
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
        if self.types!.count > 1 && self.types![0] == "normal" {
            self.types!.swapAt(0, 1)
        }
    }
}

struct Stat: Identifiable {
    let id: Int
    let name: String
    let value: Int16
}
