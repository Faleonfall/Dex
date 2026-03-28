import Foundation

enum PokedexScreenLogic {
  static func favoriteFilterIsEnabled(
    isFilterOn: Bool,
    hasFavorites: Bool
  ) -> Bool {
    isFilterOn || hasFavorites
  }

  static func refreshIDs(existingIDs: some Sequence<Int>) -> [Int] {
    PokedexProgress.missingPokemonIDs(existingIDs: existingIDs)
  }
}
