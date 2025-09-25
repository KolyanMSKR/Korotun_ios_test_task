//
//  Extension+UIImageView.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit

// MARK: - UIImageView Extension for Async Loading

extension UIImageView {

    func setImage(from urlString: String, placeholder: UIImage? = nil) {
        image = placeholder

        if let cachedImage = ImageCacheManager.shared.cachedImage(for: urlString) {
            image = cachedImage
            return
        }

        Task {
            if let loadedImage = await ImageCacheManager.shared.loadImage(from: urlString) {
                await MainActor.run {
                    self.image = loadedImage
                }
            }
        }
    }

}
