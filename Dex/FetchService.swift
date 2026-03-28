import Foundation

struct FetchService {
    enum FetchError: Error {
        case badResponse
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    // Public single-item fetch by numeric id
    func fetchPokemon(id: Int) async throws -> Pokemon {
        let url = baseURL.appendingPathComponent("\(id)")
        return try await fetchPokemon(from: url)
    }
    
    private func fetchPokemon(from url: URL) async throws -> Pokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        print("Fetched \(pokemon.id): \(pokemon.name)")
        return pokemon
    }
}
