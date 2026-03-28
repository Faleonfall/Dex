import SwiftUI

struct PokemonRow: View {
  let pokemon: Pokemon
  
  var body: some View {
    HStack {
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
            PokemonTypeBadge(type: type)
          }
        }
      }
    }
  }
}

#Preview {
  List {
    PokemonRow(pokemon: PersistenceController.previewPokemon)
  }
  .modelContainer(PersistenceController.preview)
}
