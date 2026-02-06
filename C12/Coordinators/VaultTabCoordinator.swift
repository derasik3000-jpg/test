//
//  VaultTabCoordinator.swift
//  PULSE
//
//  Vault Tab Coordinator
//

import UIKit

class VaultTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vaultScreen = EchoVaultScreen()
        navigationController.pushViewController(vaultScreen, animated: false)
    }
}
