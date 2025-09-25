import Foundation

enum PokemonListResponseMapper {
    static func map(_ data: Data) throws -> [PokemonFetchURLString] {
        let decoder = JSONDecoder()
        
        guard let root = try? decoder.decode(Root.self, from: data) else {
            throw URLError(.badServerResponse)
        }
        
        return root.asPokemonFetchURLString
    }
}

private extension PokemonListResponseMapper {
    struct Root: Decodable {
        struct Item: Decodable {
            let url: String
        }
        
        let results: [Item]
    }
}

private extension PokemonListResponseMapper.Root {
    var asPokemonFetchURLString: [PokemonFetchURLString] {
        results.map(\.url)
    }
}
