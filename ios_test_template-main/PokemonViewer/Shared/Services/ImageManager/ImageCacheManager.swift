//
//  ImageCacheManager.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit

// MARK: - Image Cache Manager

final class ImageCacheManager {

    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        cache.countLimit = 20
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    // MARK: - Public Methods

    func loadImage(from urlString: String) async -> UIImage? {
        let key = NSString(string: urlString)

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        if let existingTask = await DownloadTaskManager.shared.getTask(for: urlString) {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let image = try await downloadImage(from: urlString)
                if let image = image {
                    cache.setObject(image, forKey: key)
                }
                await DownloadTaskManager.shared.removeTask(for: urlString)
                return image
            } catch {
                await DownloadTaskManager.shared.removeTask(for: urlString)
                return nil
            }
        }

        await DownloadTaskManager.shared.setTask(task, for: urlString)
        return await task.value
    }
    
    func cachedImage(for urlString: String) -> UIImage? {
        let key = NSString(string: urlString)
        return cache.object(forKey: key)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        Task {
            await DownloadTaskManager.shared.removeAllTasks()
        }
    }

    private func downloadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return UIImage(data: data)
    }
}
