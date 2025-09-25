//
//  PokemonDetailViewController.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit
import Combine

// MARK: - Pokemon Detail View Controller

final class PokemonDetailViewController: UIViewController {
    
    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = UIColor.systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var imageLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var heightContainerView: UIView = {
        createDetailContainerView()
    }()
    
    private lazy var weightContainerView: UIView = {
        createDetailContainerView()
    }()
    
    private lazy var heightTitleLabel: UILabel = {
        createDetailTitleLabel(text: "Height")
    }()
    
    private lazy var heightValueLabel: UILabel = {
        createDetailValueLabel()
    }()
    
    private lazy var weightTitleLabel: UILabel = {
        createDetailTitleLabel(text: "Weight")
    }()
    
    private lazy var weightValueLabel: UILabel = {
        createDetailValueLabel()
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemRed
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // MARK: - Dependencies

    private let viewModel: PokemonDetailViewModel
    
    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(viewModel: PokemonDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        configureWithViewModel()
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.pokemonName
        
        setupScrollView()
        setupImageView()
        setupLabels()
        setupDetailsStack()
        setupFavoriteButton()
        setupConstraints()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupImageView() {
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(imageLoadingIndicator)
    }
    
    private func setupLabels() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
    }
    
    private func setupDetailsStack() {
        heightContainerView.addSubview(heightTitleLabel)
        heightContainerView.addSubview(heightValueLabel)

        weightContainerView.addSubview(weightTitleLabel)
        weightContainerView.addSubview(weightValueLabel)

        detailsStackView.addArrangedSubview(heightContainerView)
        detailsStackView.addArrangedSubview(weightContainerView)
        
        contentView.addSubview(detailsStackView)
    }
    
    private func setupFavoriteButton() {
        view.addSubview(favoriteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            pokemonImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            pokemonImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 200),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 200),

            imageLoadingIndicator.centerXAnchor.constraint(equalTo: pokemonImageView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: pokemonImageView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            detailsStackView.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 32),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),

            heightContainerView.heightAnchor.constraint(equalToConstant: 80),
            weightContainerView.heightAnchor.constraint(equalToConstant: 80),

            heightTitleLabel.topAnchor.constraint(equalTo: heightContainerView.topAnchor, constant: 12),
            heightTitleLabel.leadingAnchor.constraint(equalTo: heightContainerView.leadingAnchor, constant: 16),
            heightTitleLabel.trailingAnchor.constraint(equalTo: heightContainerView.trailingAnchor, constant: -16),
            
            heightValueLabel.topAnchor.constraint(equalTo: heightTitleLabel.bottomAnchor, constant: 8),
            heightValueLabel.leadingAnchor.constraint(equalTo: heightContainerView.leadingAnchor, constant: 16),
            heightValueLabel.trailingAnchor.constraint(equalTo: heightContainerView.trailingAnchor, constant: -16),

            weightTitleLabel.topAnchor.constraint(equalTo: weightContainerView.topAnchor, constant: 12),
            weightTitleLabel.leadingAnchor.constraint(equalTo: weightContainerView.leadingAnchor, constant: 16),
            weightTitleLabel.trailingAnchor.constraint(equalTo: weightContainerView.trailingAnchor, constant: -16),
            
            weightValueLabel.topAnchor.constraint(equalTo: weightTitleLabel.bottomAnchor, constant: 8),
            weightValueLabel.leadingAnchor.constraint(equalTo: weightContainerView.leadingAnchor, constant: 16),
            weightValueLabel.trailingAnchor.constraint(equalTo: weightContainerView.trailingAnchor, constant: -16),

            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 50),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        viewModel.isFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.updateFavoriteButtonAppearance(isFavorite: isFavorite)
                self?.animateFavoriteButton()
            }
            .store(in: &cancellables)
    }
    
    private func configureWithViewModel() {
        nameLabel.text = viewModel.pokemonName
        idLabel.text = viewModel.pokemonId
        heightValueLabel.text = viewModel.pokemonHeight
        weightValueLabel.text = viewModel.pokemonWeight
        updateFavoriteButtonAppearance(isFavorite: viewModel.isFavorite)
        
        loadImage()
    }
    
    private func loadImage() {
        if let cachedImage = ImageCacheManager.shared.cachedImage(for: viewModel.pokemonImageURL) {
            pokemonImageView.image = cachedImage
            return
        }
        
        imageLoadingIndicator.startAnimating()
        
        Task {
            if let image = await ImageCacheManager.shared.loadImage(from: viewModel.pokemonImageURL) {
                await MainActor.run {
                    self.imageLoadingIndicator.stopAnimating()
                    self.pokemonImageView.image = image
                }
            } else {
                await MainActor.run {
                    self.imageLoadingIndicator.stopAnimating()
                    self.pokemonImageView.image = UIImage(systemName: "photo.artframe")
                }
            }
        }
    }
    
    // MARK: - Helper Methods

    private func createDetailContainerView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func createDetailTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createDetailValueLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // MARK: - Actions

    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
    }
    
    private func updateFavoriteButtonAppearance(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = isFavorite ? UIColor.systemRed.withAlphaComponent(0.1) : .systemBackground
        favoriteButton.layer.borderColor = isFavorite ? UIColor.systemRed.cgColor : UIColor.systemGray4.cgColor
    }
    
    private func animateFavoriteButton() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = .identity
            }
        }
    }
}

