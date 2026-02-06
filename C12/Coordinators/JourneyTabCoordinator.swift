//
//  JourneyTabCoordinator.swift
//  PULSE
//
//  Journey Tab Coordinator
//

import UIKit

class JourneyTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let journeyScreen = FlowTimelineScreen()
        navigationController.pushViewController(journeyScreen, animated: false)
    }
}
