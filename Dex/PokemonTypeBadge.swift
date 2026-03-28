import SwiftUI

struct PokemonTypeBadge: View {
  @Environment(\.colorScheme) private var colorScheme

  let type: String

  var body: some View {
    Text(type.capitalized)
      .font(.subheadline)
      .fontWeight(.semibold)
      .foregroundStyle(colorScheme == .dark ? .white : .black)
      .padding(.horizontal, 13)
      .padding(.vertical, 5)
      .background(Color(type.capitalized))
      .clipShape(.capsule)
  }
}

#Preview {
  HStack {
    PokemonTypeBadge(type: "grass")
    PokemonTypeBadge(type: "poison")
  }
  .padding()
}
