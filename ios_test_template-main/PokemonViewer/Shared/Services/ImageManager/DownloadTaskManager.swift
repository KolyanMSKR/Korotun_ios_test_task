//
//  DownloadTaskManager.swift
//  PokemonViewer
//
//  Created by Anderen on 25.09.2025.
//

import UIKit

actor DownloadTaskManager {

    static let shared = DownloadTaskManager()
    
    private var tasks: [String: Task<UIImage?, Never>] = [:]
    
    func getTask(for urlString: String) -> Task<UIImage?, Never>? {
        tasks[urlString]
    }
    
    func setTask(_ task: Task<UIImage?, Never>?, for urlString: String) {
        tasks[urlString] = task
    }
    
    func removeTask(for urlString: String) {
        tasks[urlString] = nil
    }
    
    func removeAllTasks() {
        tasks.removeAll()
    }

}
