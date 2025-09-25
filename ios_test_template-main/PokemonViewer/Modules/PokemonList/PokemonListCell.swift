//
//  PokemonListCell.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit

// MARK: - Pokemon List Cell

final class PokemonListCell: UITableViewCell {

    static let identifier = "PokemonListCell"
    
    // MARK: - UI Components

    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Callbacks

    var onDelete: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?
    
    // MARK: - Image Loading

    private var imageTask: Task<Void, Never>?
    
    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        pokemonImageView.image = nil
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(idLabel)
        
        buttonStackView.addArrangedSubview(favoriteButton)
        buttonStackView.addArrangedSubview(deleteButton)
        
        contentView.addSubview(pokemonImageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(stackView)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(favoriteImageView)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pokemonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pokemonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 60),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 60),

            activityIndicator.centerXAnchor.constraint(equalTo: pokemonImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: pokemonImageView.centerYAnchor),

            stackView.leadingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: buttonStackView.leadingAnchor, constant: -16),

            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),

            favoriteImageView.topAnchor.constraint(equalTo: pokemonImageView.topAnchor, constant: -4),
            favoriteImageView.trailingAnchor.constraint(equalTo: pokemonImageView.trailingAnchor, constant: 4),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 16),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 16),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    // MARK: - Configuration

    func configure(with pokemon: Pokemon, isFavorite: Bool = false, showDeleteButton: Bool = true) {
        nameLabel.text = pokemon.name.capitalized
        idLabel.text = "#\(pokemon.id)"
        deleteButton.isHidden = !showDeleteButton
        favoriteImageView.isHidden = !isFavorite
        favoriteButton.isSelected = isFavorite
        
        loadImage(from: pokemon.imageURLString)
    }
    
    private func loadImage(from urlString: String) {
        if let cachedImage = ImageCacheManager.shared.cachedImage(for: urlString) {
            pokemonImageView.image = cachedImage
            return
        }
        
        activityIndicator.startAnimating()
        
        imageTask = Task {
            if let image = await ImageCacheManager.shared.loadImage(from: urlString) {
                await MainActor.run {
                    if !Task.isCancelled {
                        self.activityIndicator.stopAnimating()
                        self.pokemonImageView.image = image
                    }
                }
            } else {
                await MainActor.run {
                    if !Task.isCancelled {
                        self.activityIndicator.stopAnimating()
                        self.pokemonImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
    
    @objc private func favoriteButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
        
        onFavoriteToggle?()
    }
}
