//
//  FavoritesManager.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import Foundation
import Combine

// MARK: - Favorites Manager

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoritePokemonIds"
    
    @Published private(set) var favoritePokemonIds: Set<Int> = []
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods

    func isFavorite(_ pokemon: Pokemon) -> Bool {
        favoritePokemonIds.contains(pokemon.id)
    }
    
    func toggleFavorite(_ pokemon: Pokemon) {
        if favoritePokemonIds.contains(pokemon.id) {
            removeFavorite(pokemon)
        } else {
            addFavorite(pokemon)
        }
    }
    
    func addFavorite(_ pokemon: Pokemon) {
        favoritePokemonIds.insert(pokemon.id)
        saveFavorites()
    }
    
    func removeFavorite(_ pokemon: Pokemon) {
        favoritePokemonIds.remove(pokemon.id)
        saveFavorites()
    }
    
    func removeFavoriteById(_ id: Int) {
        favoritePokemonIds.remove(id)
        saveFavorites()
    }
    
    var favoritesCount: Int {
        favoritePokemonIds.count
    }
    
    // MARK: - Publisher

    var favoritesPublisher: AnyPublisher<Set<Int>, Never> {
        $favoritePokemonIds.eraseToAnyPublisher()
    }
    // MARK: - Private Methods

    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            favoritePokemonIds = ids
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoritePokemonIds) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}
