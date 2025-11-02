//
//  WidgetPokemon.swift
//  Dex
//
//  Created by Volodymyr Kryvytskyi on 30.11.2024.
//

import SwiftUI

enum WidgetSize {
    case small, medium, large
}

struct WidgetPokemon: View {
    @EnvironmentObject var pokemon: Pokemon
    let widgetSize: WidgetSize
    
    var body: some View {
        ZStack {
            Color(pokemon.types![0].capitalized)
            
            switch widgetSize {
            case .small:
                FetchedImage(url: pokemon.sprite)
            case .medium:
                HStack {
                    FetchedImage(url: pokemon.sprite)
                    
                    VStack(alignment: .leading) {
                        Text(pokemon.name!.capitalized)
                            .font(.title)
                        
                        Text(pokemon.types!.joined(separator: ", ").capitalized)
                    }
                    .padding(.trailing, 30)
                }
            case .large:
                FetchedImage(url: pokemon.sprite)
                
                VStack {
                    HStack {
                        Text(pokemon.name!.capitalized)
                            .font(.largeTitle)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text(pokemon.types!.joined(separator: ", ").capitalized)
                            .font(.title2)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    WidgetPokemon(widgetSize: .large)
        .environmentObject(SamplePokemon.samplePokemon)
}
