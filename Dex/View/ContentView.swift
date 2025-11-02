//
//  ContentView.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default
    ) private var pokedex: FetchedResults<Pokemon>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        predicate: NSPredicate(format: "favorite = %d", true),
        animation: .default
    ) private var favorites: FetchedResults<Pokemon>
    
    @State var filterByFavorites = false
    @StateObject private var pokemonVM = PokemonViewModel(controller: FetchService())
    
    var body: some View {
        switch pokemonVM.status {
        case .success:
            NavigationStack {
                List(filterByFavorites ? favorites : pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        Text(pokemon.name!.capitalized)
                            .fontWeight(.bold)
                        
                        if pokemon.favorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                .navigationTitle("Pokédex")
                .navigationDestination(for: Pokemon.self, destination: { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
                        } label: {
                            Label("Filter By favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .font(.title)
                        .foregroundStyle(.yellow)
                    }
                }
            }
            
        default:
            ProgressView()
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
