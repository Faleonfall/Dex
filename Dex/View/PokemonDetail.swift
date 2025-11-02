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
                
                AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) {
                    image in
                    image
                        .interpolation(.none)
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
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.horizontal)
                        .padding(.vertical, 7)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                }
                
                Spacer()
                
                Button {
                    pokemon.favorite.toggle()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
                .font(.largeTitle)
                .foregroundStyle(.yellow)
                
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -5)
            
            Stats()
                .environmentObject(pokemon)
            
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                        .foregroundStyle(showShiny ? .yellow : .primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail()
            .environmentObject(SamplePokemon.samplePokemon)
    }
}
