//
//  TodayCoordinator.swift
//  DAYTRACE
//
//  Today tab coordinator
//

import UIKit

final class TodayCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        let todayScreen = TodayTraceScreen()
        navigationController.setViewControllers([todayScreen], animated: false)
        
        // Set tab bar item on navigation controller
        navigationController.tabBarItem = UITabBarItem(
            title: "Today",
            image: UIImage(systemName: "sun.max"),
            tag: 0
        )
    }
}
