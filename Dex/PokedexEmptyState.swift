import SwiftUI

struct PokedexEmptyState: View {
  let isFetching: Bool
  let onFetch: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("No Pokémon", image: .nopokemon)
    } description: {
      Text("There aren't any Pokémon yet.\nFetch some Pokémon to get started!")
    } actions: {
      Button(action: onFetch) {
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
  }
}

#Preview {
  PokedexEmptyState(isFetching: false) {}
}
