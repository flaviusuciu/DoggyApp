//
//  AppCoordinator.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start () {
        let viewController = PetsListViewController.instantiate(viewModel: PetsListViewModel())
        let navigationContorller = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationContorller
        window.makeKeyAndVisible()
    }
}
