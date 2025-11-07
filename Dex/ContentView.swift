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

    // Local status to replace the ViewModel’s status
    enum Status: Equatable {
        case notStarted
        case fetching
        case success
        case failed(error: Error)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.notStarted, .notStarted),
                 (.fetching, .fetching),
                 (.success, .success):
                return true
            case (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }

    @State private var status: Status = .notStarted

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

    // Use a simple fetcher instance
    private let fetcher = FetchService()

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
                            if status == .fetching {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(status == .fetching ? "Fetching Pokémon…" : "Fetch Pokémon")
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
                                }
                            }
                        }
                    }
                    .navigationTitle("Pokédex")
                    .searchable(text: $searchText, prompt: "Find a Pokémon")
                    .autocorrectionDisabled()
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
    }

    private func toggleFavorite(for pokemon: Pokemon, in context: ModelContext) {
        pokemon.favorite.toggle()

        do {
            try context.save()
        } catch {
            print("Failed to save favorite state: \(error.localizedDescription)")
        }
    }

    // Exactly as requested: Task-based, per-id, insert directly, then storeSprites()
    private func getPokemon(from id: Int) {
        Task {
            for i in id..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id: i)
                    modelContext.insert(fetchedPokemon)
                } catch {
                    print(error)
                }
            }
            storeSprites()
        }
    }

    // Exactly as requested: iterate pokedex, fetch sprite/shiny, save each, print
    private func storeSprites() {
        Task {
            do {
                for pokemon in pokedex {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    
                    try modelContext.save()
                    
                    print("Sprites stored: (\(pokemon.id)) : \(pokemon.name.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    // Ensure SwiftData's modifier is chosen by the compiler
    ContentView()
        .modelContainer(PersistenceController.preview)
}

