//
//  SceneDelegate.swift
//  PokemonViewer
//
//  Created by Maksym Soroka on 12.09.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var router: Router?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        let router = MainRouter(navigationController: navigationController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        self.router = router
        self.router?.start()
    }

}
