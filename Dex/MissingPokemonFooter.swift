import SwiftUI

struct MissingPokemonFooter: View {
  let isFetching: Bool
  let onFetch: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Missing Pokémon", image: .nopokemon)
    } description: {
      Text("The fetch was interrupted!\nFetch the rest of the Pokémon.")
    } actions: {
      Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right", action: onFetch)
        .buttonStyle(.borderedProminent)
        .disabled(isFetching)
    }
  }
}

#Preview {
  MissingPokemonFooter(isFetching: false) {}
}
