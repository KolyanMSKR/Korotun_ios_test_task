//
//  PokemonDetailViewModel.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import Combine
import UIKit

// MARK: - Pokemon Detail View Model

final class PokemonDetailViewModel {
    private let pokemon: Pokemon
    private weak var router: Router?
    private let favoritesManager = FavoritesManager.shared
    
    var pokemonName: String { pokemon.name.capitalized }
    var pokemonId: String { "#\(pokemon.id)" }
    var pokemonImageURL: String { pokemon.imageURLString }
    var pokemonHeight: String { "\(Double(pokemon.height) / 10.0) m" }
    var pokemonWeight: String { "\(Double(pokemon.weight) / 10.0) kg" }
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(pokemon)
    }

    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        favoritesManager.favoritesPublisher
            .map { [pokemonID = pokemon.id] ids in
                ids.contains(pokemonID)
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    init(pokemon: Pokemon, router: Router) {
        self.pokemon = pokemon
        self.router = router
    }
    
    func toggleFavorite() {
        favoritesManager.toggleFavorite(pokemon)
    }
}
