import XCTest
@testable import Dex

final class PokedexProgressTests: XCTestCase {
  func testMissingPokemonIDsReturnsFullRangeForEmptyStore() {
    let missingIDs = PokedexProgress.missingPokemonIDs(existingIDs: [])

    XCTAssertEqual(missingIDs, Array(1...151))
  }

  func testMissingPokemonIDsReturnsOnlyGapsInAscendingOrder() {
    let missingIDs = PokedexProgress.missingPokemonIDs(existingIDs: [1, 2, 4, 7])

    XCTAssertEqual(missingIDs.prefix(5), [3, 5, 6, 8, 9])
    XCTAssertEqual(missingIDs.last, 151)
  }

  func testMissingPokemonIDsReturnsEmptyArrayForFullRange() {
    let missingIDs = PokedexProgress.missingPokemonIDs(existingIDs: Array(1...151))

    XCTAssertTrue(missingIDs.isEmpty)
  }

  func testMissingPokemonIDsIgnoresDuplicates() {
    let missingIDs = PokedexProgress.missingPokemonIDs(existingIDs: [1, 1, 2, 2, 151])

    XCTAssertFalse(missingIDs.contains(1))
    XCTAssertFalse(missingIDs.contains(2))
    XCTAssertFalse(missingIDs.contains(151))
    XCTAssertEqual(missingIDs.count, 148)
  }

  func testFavoriteFilterIsDisabledWithoutFavoritesWhenFilterIsOff() {
    let isEnabled = PokedexScreenLogic.favoriteFilterIsEnabled(
      isFilterOn: false,
      hasFavorites: false
    )

    XCTAssertFalse(isEnabled)
  }

  func testFavoriteFilterStaysEnabledWhenFilterIsOn() {
    let isEnabled = PokedexScreenLogic.favoriteFilterIsEnabled(
      isFilterOn: true,
      hasFavorites: false
    )

    XCTAssertTrue(isEnabled)
  }

  func testRefreshIDsNoOpWhenNothingIsMissing() {
    let refreshIDs = PokedexScreenLogic.refreshIDs(existingIDs: Array(1...151))

    XCTAssertTrue(refreshIDs.isEmpty)
  }

  func testPokemonDecodesCoreFieldsFromAPIResponse() throws {
    let data = Data(
      """
      {
        "id": 1,
        "name": "bulbasaur",
        "types": [
          { "type": { "name": "grass" } },
          { "type": { "name": "poison" } }
        ],
        "stats": [
          { "base_stat": 45, "stat": { "name": "hp" } },
          { "base_stat": 49, "stat": { "name": "attack" } },
          { "base_stat": 49, "stat": { "name": "defense" } },
          { "base_stat": 65, "stat": { "name": "special-attack" } },
          { "base_stat": 65, "stat": { "name": "special-defense" } },
          { "base_stat": 45, "stat": { "name": "speed" } }
        ],
        "sprites": {
          "front_default": "https://example.com/bulbasaur.png",
          "front_shiny": "https://example.com/bulbasaur-shiny.png"
        }
      }
      """.utf8
    )

    let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)

    XCTAssertEqual(pokemon.id, 1)
    XCTAssertEqual(pokemon.name, "bulbasaur")
    XCTAssertEqual(pokemon.types, ["grass", "poison"])
    XCTAssertEqual(pokemon.hp, 45)
    XCTAssertEqual(pokemon.attack, 49)
    XCTAssertEqual(pokemon.defense, 49)
    XCTAssertEqual(pokemon.specialAttack, 65)
    XCTAssertEqual(pokemon.specialDefense, 65)
    XCTAssertEqual(pokemon.speed, 45)
    XCTAssertEqual(pokemon.spriteURL.absoluteString, "https://example.com/bulbasaur.png")
    XCTAssertEqual(pokemon.shinyURL.absoluteString, "https://example.com/bulbasaur-shiny.png")
  }

  @MainActor
  func testFetchBatchingDeliversFullAndPartialBatchesInOrder() async {
    var receivedBatches: [[Int]] = []

    await PokedexFetchRunner.fetchBatching(
      ids: [1, 2, 3, 4, 5],
      batchSize: 2,
      fetch: { $0 },
      onBatch: { receivedBatches.append($0) },
      onError: { _, _ in
        XCTFail("Did not expect fetch errors")
      }
    )

    XCTAssertEqual(receivedBatches, [[1, 2], [3, 4], [5]])
  }

  @MainActor
  func testFetchBatchingWaitsForAsyncFetchCompletionBeforeReturning() async {
    let clock = ContinuousClock()
    let start = clock.now
    var didFinishFetch = false

    await PokedexFetchRunner.fetchBatching(
      ids: [1],
      batchSize: 10,
      fetch: { id in
        try? await Task.sleep(for: .milliseconds(150))
        didFinishFetch = true
        return id
      },
      onBatch: { _ in },
      onError: { _, _ in
        XCTFail("Did not expect fetch errors")
      }
    )

    let elapsed = start.duration(to: clock.now)

    XCTAssertTrue(didFinishFetch)
    XCTAssertGreaterThanOrEqual(elapsed, .milliseconds(150))
  }
}
