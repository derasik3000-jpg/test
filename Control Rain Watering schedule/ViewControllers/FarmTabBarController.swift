//
//  FarmTabBarController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class FarmTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
        
        // Update streak on app open
        BarnStorageManager.shared.updateStreak()
    }
    
    // MARK: - Setup
    
    private func setupTabs() {
        let harvestCalendar = HarvestCalendarViewController()
        let harvestNav = UINavigationController(rootViewController: harvestCalendar)
        setupNavigationBarAppearance(for: harvestNav)
        harvestNav.tabBarItem = UITabBarItem(
            title: "Calendar",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.badge.clock")
        )
        
        let fieldManager = FieldManagerViewController()
        let fieldNav = UINavigationController(rootViewController: fieldManager)
        setupNavigationBarAppearance(for: fieldNav)
        fieldNav.tabBarItem = UITabBarItem(
            title: "Fields",
            image: UIImage(systemName: "square.grid.2x2"),
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )
        
        let barnDashboard = BarnDashboardViewController()
        let barnNav = UINavigationController(rootViewController: barnDashboard)
        setupNavigationBarAppearance(for: barnNav)
        barnNav.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        viewControllers = [harvestNav, fieldNav, barnNav]
    }
    
    private func setupNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = FarmPalette.richSoil
        
        // Add visible bottom border
        let borderImage = UIImage.imageWithColor(color: FarmPalette.goldenHarvest.withAlphaComponent(0.5), size: CGSize(width: 1, height: 1))
        appearance.shadowImage = borderImage
        
        appearance.titleTextAttributes = [
            .foregroundColor: FarmPalette.goldenHarvest,
            .font: FarmTypography.barn
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: FarmPalette.goldenHarvest,
            .font: FarmTypography.silo
        ]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = FarmPalette.goldenHarvest
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = FarmPalette.richSoil
        navigationController.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = FarmPalette.richSoil
        
        appearance.stackedLayoutAppearance.normal.iconColor = FarmPalette.dustyField
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: FarmPalette.dustyField
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = FarmPalette.goldenHarvest
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: FarmPalette.goldenHarvest
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

// Helper extension to create colored image
extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
