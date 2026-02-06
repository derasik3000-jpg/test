//
//  IntroPulseCoordinator.swift
//  PULSE
//
//  Onboarding Coordinator
//

import UIKit

class IntroPulseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: RootSpineCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let pages: [UIViewController] = [
            IntroRhythmScene(coordinator: self, pageIndex: 0),
            IntroMomentsScene(coordinator: self, pageIndex: 1),
            IntroBalanceScene(coordinator: self, pageIndex: 2)
        ]
        
        let onboardingContainer = OnboardingContainerViewController(pages: pages, coordinator: self)
        navigationController.setViewControllers([onboardingContainer], animated: true)
    }
    
    func skip() {
        parentCoordinator?.onboardingCompleted()
    }
    
    func complete() {
        parentCoordinator?.onboardingCompleted()
    }
}
