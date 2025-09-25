//
//  PokemonListViewController.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit
import Combine

// MARK: - Pokemon List View Controller

final class PokemonListViewController: UIViewController {
    
    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PokemonListCell.self, forCellReuseIdentifier: PokemonListCell.identifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Pokémon found"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Dependencies

    private let viewModel: PokemonListViewModel
    
    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(viewModel: PokemonListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Pokémon"
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let favoritesButton = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.rightBarButtonItem = favoritesButton

        updateFavoritesButton()
    }
    
    private func updateFavoritesButton() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        
        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.tintColor = .systemRed
        heartImageView.contentMode = .scaleAspectFit
        
        let countLabel = UILabel()
        countLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        countLabel.textColor = .label
        countLabel.text = "\(FavoritesManager.shared.favoritesCount)"
        
        stackView.addArrangedSubview(heartImageView)
        stackView.addArrangedSubview(countLabel)
        
        let customButton = UIBarButtonItem(customView: stackView)
        navigationItem.rightBarButtonItem = customButton
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func bindViewModel() {
        viewModel.pokemonsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading && self.viewModel.pokemonsCount == 0 {
                    self.loadingIndicator.startAnimating()
                    self.tableView.isHidden = true
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.favoritesCountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFavoritesButton()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.errorPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.pokemonsCount == 0
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions

    @objc private func refreshData() {
        viewModel.refresh()
    }

}

// MARK: - Table View Data Source

extension PokemonListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pokemonsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PokemonListCell.identifier,
            for: indexPath
        ) as? PokemonListCell else {
            return UITableViewCell()
        }
        
        let pokemon = viewModel.pokemon(at: indexPath.row)
        let isFavorite = FavoritesManager.shared.isFavorite(pokemon)
        
        cell.configure(with: pokemon, isFavorite: isFavorite)
        
        cell.onDelete = { [weak self] in
            self?.showDeleteConfirmation(for: indexPath)
        }
        
        cell.onFavoriteToggle = {
            FavoritesManager.shared.toggleFavorite(pokemon)
        }
        
        return cell
    }

}

// MARK: - Table View Delegate

extension PokemonListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectPokemon(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(for: indexPath.row)
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let pokemon = viewModel.pokemon(at: indexPath.row)
        
        let alert = UIAlertController(
            title: "Delete Pokémon",
            message: "Are you sure you want to delete \(pokemon.name.capitalized)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deletePokemon(at: indexPath.row)
        })
        
        present(alert, animated: true)
    }

}
