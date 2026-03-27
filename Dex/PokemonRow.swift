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
  }
}

#Preview {
  List {
    PokemonRow(pokemon: PersistenceController.previewPokemon)
  }
  .modelContainer(PersistenceController.preview)
}
