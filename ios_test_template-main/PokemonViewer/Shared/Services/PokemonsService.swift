import Foundation

protocol PokemonsService {
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon]
}

final class PokemonsServiceImpl: PokemonsService {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }
    
    func fetchPokemons(offset: Int, limit: Int) async throws -> [Pokemon] {
        let listRequest = try PokemonEndpoint.list(offset: offset, limit: limit).makeRequest()
        let (data, response) = try await httpClient.send(listRequest)
        guard (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let pokemonFetchURLStrings = try PokemonListResponseMapper.map(data)
        
        return try await withThrowingTaskGroup(of:  Pokemon.self) { taskGroup in
            for fetchURLString in pokemonFetchURLStrings {
                taskGroup.addTask { [httpClient] in
                    guard let detailURL = URL(string: fetchURLString) else {
                        throw URLError(.badURL)
                    }
                    
                    let request = try PokemonEndpoint.detail(url: detailURL).makeRequest()
                    let (data, response) = try await httpClient.send(request)
                    guard (200..<300).contains(response.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    
                    let pokemon = try PokemonDetailResponseMapper.map(data)
                    return pokemon
                }
            }
            
            var pokemons: [Pokemon] = []
            
            for try await pokemon in taskGroup {
                pokemons.append(pokemon)
            }
            
            return pokemons
        }
    }
}

