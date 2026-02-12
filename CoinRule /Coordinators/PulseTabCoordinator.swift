//
//  PulseTabCoordinator.swift
//  PULSE
//
//  Pulse Tab Coordinator
//

import UIKit

class PulseTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let pulseScreen = PulseCoreScreen()
        navigationController.pushViewController(pulseScreen, animated: false)
    }
}
