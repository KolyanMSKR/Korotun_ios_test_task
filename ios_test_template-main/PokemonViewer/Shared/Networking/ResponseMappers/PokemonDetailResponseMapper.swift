import Foundation

enum PokemonDetailResponseMapper {
    static func map(_ data: Data) throws -> Pokemon {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let root = try? decoder.decode(RemotePokemon.self, from: data) else {
            throw URLError(.badServerResponse)
        }
        
        return root.asPokemon
    }
}

private extension PokemonDetailResponseMapper {
    struct RemotePokemon: Decodable {
        struct Sprites: Decodable {
            let frontDefault: String
        }
        
        let id: Int
        var name: String
        let height: Int
        let weight: Int
        let sprites: Sprites
    }
}

private extension PokemonDetailResponseMapper.RemotePokemon {
    var asPokemon: Pokemon {
        .init(
            id: id,
            name: name,
            height: height,
            weight: weight,
            imageURLString: sprites.frontDefault
        )
    }
}
