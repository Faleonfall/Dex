//
//  ContentView.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    ) private var pokedex
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    @StateObject private var pokemonVM = PokemonViewModel(controller: FetchService())
    
    private var dynamicPredicate: NSPredicate? {
        var predicates: [NSPredicate] = []
        
        // Search
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", searchText))
        }
        
        // Filter by favorite
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        // Combine predicates (if any)
        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        if all.isEmpty {
            // Empty state
            ContentUnavailableView {
                Label("No Pokémon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokémon yet.\nFetch some Pokémon to get started!")
            } actions: {
                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                    Task {
                        await pokemonVM.getPokemon()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            // Main list
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name?.capitalized ?? "Unknown")
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite == true {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    
                                    HStack {
                                        ForEach(pokemon.types ?? [], id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggleFavorite(for: pokemon, in: viewContext)
                                } label: {
                                    Label(
                                        pokemon.favorite ? "Remove from Favorites" : "Add to Favorites",
                                        systemImage: pokemon.favorite ? "star.slash" : "star"
                                    )
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if all.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokémon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the Pokémon.")
                            } actions: {
                                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                                    Task {
                                        await pokemonVM.getPokemon()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                .navigationTitle("Pokédex")
                .searchable(text: $searchText, prompt: "Find a Pokémon")
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of: filterByFavorites) {
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
                        } label: {
                            Label("Filter By Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    }
    
    private func toggleFavorite(for pokemon: Pokemon, in context: NSManagedObjectContext) {
        pokemon.objectWillChange.send()
        pokemon.favorite.toggle()
        
        do {
            try context.save()
            context.refresh(pokemon, mergeChanges: true)
        } catch {
            print("Failed to save favorite state: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
