//
//  SamplePokemon.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 29.11.2024.
//

import Foundation
import CoreData

struct SamplePokemon {
    @MainActor static let samplePokemon = {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try! context.fetch(fetchRequest)
        
        return results.first!
    }()
}
