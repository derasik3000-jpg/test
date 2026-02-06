//
//  MainOrbitCoordinator.swift
//  PULSE
//
//  Main Tab Coordinator
//

import UIKit

class MainOrbitCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var tabBarController: UITabBarController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBar = UITabBarController()
        tabBar.tabBar.backgroundColor = .pulsePrimary
        tabBar.tabBar.isTranslucent = false
        
        // Настройка appearance для гарантии черного цвета всегда
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .pulsePrimary
        
        // Функция для настройки цветов в layout appearance
        let configureLayoutAppearance: (UITabBarItemAppearance) -> Void = { layoutAppearance in
            // Цвет для выбранных элементов - всегда черный
            layoutAppearance.selected.iconColor = .black
            layoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.black
            ]
            
            // Цвет для невыбранных элементов - черный с прозрачностью
            layoutAppearance.normal.iconColor = UIColor.black.withAlphaComponent(0.5)
            layoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.black.withAlphaComponent(0.5)
            ]
        }
        
        // Настраиваем все возможные layout appearances
        configureLayoutAppearance(appearance.stackedLayoutAppearance)
        configureLayoutAppearance(appearance.inlineLayoutAppearance)
        configureLayoutAppearance(appearance.compactInlineLayoutAppearance)
        
        // Применяем appearance для всех состояний
        tabBar.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.tabBar.scrollEdgeAppearance = appearance
        }
        
        // Дополнительно устанавливаем tintColor для совместимости и гарантии
        tabBar.tabBar.tintColor = .black
        tabBar.tabBar.unselectedItemTintColor = UIColor.black.withAlphaComponent(0.5)
        
        // Переопределяем цвета при каждом появлении tab bar
        tabBar.tabBar.overrideUserInterfaceStyle = .light
        
        // Create coordinators for each tab
        let pulseNav = UINavigationController()
        pulseNav.setNavigationBarHidden(true, animated: false)
        let pulseCoordinator = PulseTabCoordinator(navigationController: pulseNav)
        addChild(pulseCoordinator)
        
        let journeyNav = UINavigationController()
        journeyNav.setNavigationBarHidden(true, animated: false)
        let journeyCoordinator = JourneyTabCoordinator(navigationController: journeyNav)
        addChild(journeyCoordinator)
        
        let vaultNav = UINavigationController()
        vaultNav.setNavigationBarHidden(true, animated: false)
        let vaultCoordinator = VaultTabCoordinator(navigationController: vaultNav)
        addChild(vaultCoordinator)
        
        // Start coordinators
        pulseCoordinator.start()
        journeyCoordinator.start()
        vaultCoordinator.start()
        
        // Configure tab bar items
        pulseNav.tabBarItem = UITabBarItem(title: "Expenses", image: createCircleIcon(), tag: 0)
        journeyNav.tabBarItem = UITabBarItem(title: "History", image: createLineIcon(), tag: 1)
        vaultNav.tabBarItem = UITabBarItem(title: "Stats", image: createSquareIcon(), tag: 2)
        
        tabBar.viewControllers = [pulseNav, journeyNav, vaultNav]
        
        self.tabBarController = tabBar
        navigationController.setViewControllers([tabBar], animated: true)
    }
    
    // MARK: - Icon Creation
    
    private func createCircleIcon() -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(x: 4, y: 4, width: 20, height: 20))
            UIColor.pulsePrimary.setStroke()
            path.lineWidth = 2
            path.stroke()
        }.withRenderingMode(.alwaysTemplate)
    }
    
    private func createLineIcon() -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 4, y: 14))
            path.addLine(to: CGPoint(x: 24, y: 14))
            UIColor.pulsePrimary.setStroke()
            path.lineWidth = 2
            path.stroke()
        }.withRenderingMode(.alwaysTemplate)
    }
    
    private func createSquareIcon() -> UIImage? {
        let size = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let path = UIBezierPath(rect: CGRect(x: 4, y: 4, width: 20, height: 20))
            UIColor.pulsePrimary.setStroke()
            path.lineWidth = 2
            path.stroke()
        }.withRenderingMode(.alwaysTemplate)
    }
}
