//
//  ProfileCoordinator.swift
//  DAYTRACE
//
//  Profile tab coordinator
//

import UIKit

final class ProfileCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        let profileScreen = PersonalVaultScreen()
        navigationController.setViewControllers([profileScreen], animated: false)
        
        // Set tab bar item on navigation controller
        navigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle"),
            tag: 2
        )
    }
}
