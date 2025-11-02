//
//  PokemonDetail.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 29.11.2024.
//

import SwiftUI
import CoreData

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var pokemon: Pokemon
    @State var showShiny = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                
                AsyncImage(url: showShiny ? pokemon.shiny : pokemon.sprite) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
            
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
                
                Spacer()
                
                Button {
                    withAnimation {
                        pokemon.favorite.toggle()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                } label: {
                    pokemon.favorite ? Image(systemName: "star.fill") : Image(systemName: "star")
                }
                .font(.largeTitle)
                .foregroundStyle(.yellow)

            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            
            Stats()
                .environmentObject(pokemon)
            
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    if showShiny {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.yellow)
                    } else {
                        Image(systemName: "wand.and.stars.inverse")
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonDetail()
        .environmentObject(SamplePokemon.samplePokemon)
}
