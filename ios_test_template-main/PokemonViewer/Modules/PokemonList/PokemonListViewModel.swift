//
//  PokemonListViewModel.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import Foundation
import Combine

// MARK: - Pokemon List View Model

final class PokemonListViewModel {
    
    // MARK: - Dependencies

    private let pokemonsService: PokemonsService
    private weak var router: Router?
    private let favoritesManager = FavoritesManager.shared
    
    // MARK: - State

    @Published private var pokemons: [Pokemon] = []
    @Published private var isLoading = false
    @Published private var favoritesCount: Int = 0
    private var currentOffset = 0
    private let pageSize = 20
    private var hasMorePages = true
    
    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Publishers

    var pokemonsPublisher: AnyPublisher<[Pokemon], Never> {
        $pokemons.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var favoritesCountPublisher: AnyPublisher<Int, Never> {
        $favoritesCount.eraseToAnyPublisher()
    }
    
    @Published private var currentError: Error?
    var errorPublisher: AnyPublisher<Error?, Never> {
        $currentError.eraseToAnyPublisher()
    }

    var onPokemonsUpdated: (([Pokemon]) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    // MARK: - Public Properties

    var pokemonsCount: Int { pokemons.count }
    
    // MARK: - Initialization

    init(
        pokemonsService: PokemonsService,
        router: Router
    ) {
        self.pokemonsService = pokemonsService
        self.router = router
        setupObservers()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods

    func viewDidLoad() {
        loadPokemons()
    }
    
    func pokemon(at index: Int) -> Pokemon {
        pokemons[index]
    }
    
    func deletePokemon(at index: Int) {
        let pokemon = pokemons[index]
        favoritesManager.removeFavoriteById(pokemon.id)
        pokemons.remove(at: index)
        onPokemonsUpdated?(pokemons)
    }
    
    func didSelectPokemon(at index: Int) {
        let pokemon = pokemons[index]
        router?.showPokemonDetail(pokemon)
    }
    
    func loadMoreIfNeeded(for index: Int) {
        let thresholdIndex = pokemons.count - 5
        if index >= thresholdIndex && !isLoading && hasMorePages {
            loadPokemons()
        }
    }
    
    func refresh() {
        currentOffset = 0
        hasMorePages = true
        pokemons.removeAll()
        loadPokemons()
    }
    
    // MARK: - Private Methods

    private func setupObservers() {
        $pokemons
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pokemons in
                self?.onPokemonsUpdated?(pokemons)
            }
            .store(in: &cancellables)
        
        $isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.onLoadingStateChanged?(isLoading)
            }
            .store(in: &cancellables)
        
        $currentError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.onError?(error)
            }
            .store(in: &cancellables)

        favoritesManager.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                self?.favoritesCount = favoriteIds.count
                if let pokemons = self?.pokemons {
                    self?.onPokemonsUpdated?(pokemons)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadPokemons() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        
        Task {
            do {
                let newPokemons = try await pokemonsService.fetchPokemons(
                    offset: currentOffset,
                    limit: pageSize
                )
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if newPokemons.isEmpty {
                        self.hasMorePages = false
                    } else {
                        self.pokemons.append(contentsOf: newPokemons)
                        self.currentOffset += self.pageSize
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.currentError = error
                }
            }
        }
    }

}
