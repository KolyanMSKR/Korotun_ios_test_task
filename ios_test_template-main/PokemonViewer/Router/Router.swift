//
//  SceneDelegate.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit

// MARK: - Router Protocol

protocol Router: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
    func showPokemonList()
    func showPokemonDetail(_ pokemon: Pokemon)
}

// MARK: - Main Router Implementation

final class MainRouter: Router {

    let navigationController: UINavigationController
    private let pokemonsService: PokemonsService
    
    init(
        navigationController: UINavigationController,
        pokemonsService: PokemonsService = PokemonsServiceImpl()
    ) {
        self.navigationController = navigationController
        self.pokemonsService = pokemonsService
    }

    func start() {
        showPokemonList()
    }
    
    func showPokemonList() {
        let viewModel = PokemonListViewModel(
            pokemonsService: pokemonsService,
            router: self
        )
        let viewController = PokemonListViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showPokemonDetail(_ pokemon: Pokemon) {
        let viewModel = PokemonDetailViewModel(
            pokemon: pokemon,
            router: self
        )
        let viewController = PokemonDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

}
