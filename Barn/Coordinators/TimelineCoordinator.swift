//
//  TimelineCoordinator.swift
//  DAYTRACE
//
//  Timeline tab coordinator
//

import UIKit

final class TimelineCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        let timelineScreen = LifeTimelineScreen()
        navigationController.setViewControllers([timelineScreen], animated: false)
        
        // Set tab bar item on navigation controller
        navigationController.tabBarItem = UITabBarItem(
            title: "Timeline",
            image: UIImage(systemName: "calendar"),
            tag: 1
        )
    }
}
