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

  private var missingPokemonIDs: [Int] {
    PokedexScreenLogic.refreshIDs(existingIDs: pokedex.map(\.id))
  }

  private var hasFavorites: Bool {
    pokedex.contains(where: \.favorite)
  }
  
  var body: some View {
    NavigationStack {
      Group {
        if pokedex.isEmpty {
          PokedexEmptyState(isFetching: isFetching) {
            Task {
              await fetchPokemon(ids: Array(1...151))
            }
          }
        } else {
          List {
            Section {
              ForEach(filteredPokedex) { pokemon in
                NavigationLink(value: pokemon) {
                  PokemonRow(pokemon: pokemon)
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
                MissingPokemonFooter(isFetching: isFetching) {
                  Task {
                    await fetchPokemon(ids: missingPokemonIDs)
                  }
                }
              }
            }
          }
          .refreshable {
            await performRefresh()
          }
          .navigationTitle("Pokédex")
          .searchable(text: $searchText, prompt: "Find a Pokémon")
          .autocorrectionDisabled()
        }
      }
      .navigationDestination(for: Pokemon.self) { pokemon in
        PokemonDetail(pokemon: pokemon)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          FavoriteFilterButton(
            isOn: $filterByFavorites,
            isEnabled: PokedexScreenLogic.favoriteFilterIsEnabled(
              isFilterOn: filterByFavorites,
              hasFavorites: hasFavorites
            )
          )
        }
      }
    }
    .task {
      if pokedex.isEmpty && !isFetching {
        await fetchPokemon(ids: Array(1...151))
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
  
  @MainActor
  private func fetchPokemon(ids: [Int]) async {
    guard !ids.isEmpty else { return }
    guard !isFetching else { return }
    isFetching = true

    defer { isFetching = false }
    // Insert in batches so SwiftData and the list do not refresh on every single fetch.
    await PokedexFetchRunner.fetchBatching(
      ids: ids,
      batchSize: 10,
      fetch: { id in
        try await fetcher.fetchPokemon(id: id)
      },
      onBatch: { pokemonBatch in
        for pokemon in pokemonBatch {
          modelContext.insert(pokemon)
        }
      },
      onError: { id, error in
        print("Fetch failed for id \(id): \(error)")
      }
    )
  }

  private func performRefresh() async {
    let clock = ContinuousClock()
    let start = clock.now
    let minimumRefreshDuration = Duration.milliseconds(500)

    await fetchPokemon(ids: missingPokemonIDs)

    let elapsed = start.duration(to: clock.now)
    if elapsed < minimumRefreshDuration {
      // A tiny minimum keeps pull-to-refresh from looking like a no-op blink.
      try? await Task.sleep(for: minimumRefreshDuration - elapsed)
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(PersistenceController.preview)
}
