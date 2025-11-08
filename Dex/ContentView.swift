//
//  ContentView.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    @State private var isFetching = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: Predicate<Pokemon> {
        #Predicate<Pokemon> { pokemon in
            if filterByFavorites && !searchText.isEmpty {
                pokemon.favorite && pokemon.name.localizedStandardContains(searchText)
            } else if !searchText.isEmpty {
                pokemon.name.localizedStandardContains(searchText)
            } else if filterByFavorites {
                pokemon.favorite
            } else {
                true
            }
        }
    }
    
    private var filteredPokedex: [Pokemon] {
        (try? pokedex.filter(dynamicPredicate)) ?? pokedex
    }
    
    var body: some View {
        Group {
            if pokedex.isEmpty {
                // Empty state
                ContentUnavailableView {
                    Label("No Pokémon", image: .nopokemon)
                } description: {
                    Text("There aren't any Pokémon yet.\nFetch some Pokémon to get started!")
                } actions: {
                    Button {
                        getPokemon(from: 1)
                    } label: {
                        HStack {
                            if isFetching {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isFetching ? "Fetching Pokémon…" : "Fetch Pokémon")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isFetching)
                }
            } else {
                // Main list
                NavigationStack {
                    List {
                        Section {
                            ForEach(filteredPokedex) { pokemon in
                                NavigationLink(value: pokemon) {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .interpolation(.none)
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(pokemon.name.capitalized)
                                                .fontWeight(.bold)
                                            
                                            if pokemon.favorite {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        
                                        HStack {
                                            ForEach(pokemon.types, id: \.self) { type in
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
                                        toggleFavorite(for: pokemon, in: modelContext)
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
                            if pokedex.count < 151 {
                                ContentUnavailableView {
                                    Label("Missing Pokémon", image: .nopokemon)
                                } description: {
                                    Text("The fetch was interrupted!\nFetch the rest of the Pokémon.")
                                } actions: {
                                    Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                                        // Continue from the highest existing id + 1
                                        let nextStart = (pokedex.map(\.id).max() ?? 0) + 1
                                        getPokemon(from: max(1, nextStart))
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(isFetching)
                                }
                            }
                        }
                    }
                    .navigationTitle("Pokédex")
                    .searchable(text: $searchText, prompt: "Find a Pokémon")
                    .autocorrectionDisabled()
                    .animation(.default, value: searchText)
                    .navigationDestination(for: Pokemon.self) { pokemon in
                        PokemonDetail(pokemon: pokemon)
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
        // Auto-seed on first launch (or after uninstall) if the store is empty.
        .task {
            if pokedex.isEmpty && !isFetching {
                getPokemon(from: 1)
            }
        }
    }
    
    @MainActor
    private func toggleFavorite(for pokemon: Pokemon, in context: ModelContext) {
        pokemon.favorite.toggle()
        
        do {
            try context.save()
        } catch {
            print("Failed to save favorite state: \(error.localizedDescription)")
        }
    }
    
    // Task-based, per-id, insert directly
    @MainActor
    private func getPokemon(from id: Int) {
        guard !isFetching else { return }
        isFetching = true
        
        Task {
            defer { isFetching = false }
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id: i)
                    modelContext.insert(fetchedPokemon)
                } catch {
                    print("Fetch failed for id \(i): \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
