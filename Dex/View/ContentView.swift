//
//  ContentView.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 26.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    ) private var pokedex
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        predicate: NSPredicate(format: "favorite = %d", true),
        animation: .default
    ) private var favorites
    
    @State var filterByFavorites = false
    @State private var searchText = ""
    
    @StateObject private var pokemonVM = PokemonViewModel(controller: FetchService())
    
    private var dynamicPredicate: NSPredicate? {
        var predicates: [NSPredicate] = []
        
        // Search
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        // Filter by favorite
        
        // Combine
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
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
                        
                        VStack(alignment: .leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)
                            
                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
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
                        
                        if pokemon.favorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                .navigationTitle("Pokédex")
                .searchable(text: $searchText, prompt: "Find a Pokémon")
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    pokedex.nsPredicate = dynamicPredicate
                }
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
