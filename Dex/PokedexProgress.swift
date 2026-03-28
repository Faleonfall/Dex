import Foundation

enum PokedexProgress {
  static let pokemonRange = 1...151

  static func missingPokemonIDs(
    existingIDs: some Sequence<Int>,
    in range: ClosedRange<Int> = pokemonRange
  ) -> [Int] {
    let existingIDs = Set(existingIDs)
    return range.filter { !existingIDs.contains($0) }
  }
}
