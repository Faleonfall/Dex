import Foundation

enum PokedexFetchRunner {
  @MainActor
  static func fetchBatching<Element>(
    ids: [Int],
    batchSize: Int,
    fetch: (Int) async throws -> Element,
    onBatch: ([Element]) -> Void,
    onError: (Int, Error) -> Void
  ) async {
    // This helper keeps the async fetch loop testable without involving the view.
    var batch: [Element] = []

    for id in ids {
      do {
        let element = try await fetch(id)
        batch.append(element)

        if batch.count == batchSize {
          onBatch(batch)
          batch.removeAll(keepingCapacity: true)
        }
      } catch {
        onError(id, error)
      }
    }

    if !batch.isEmpty {
      onBatch(batch)
    }
  }
}
