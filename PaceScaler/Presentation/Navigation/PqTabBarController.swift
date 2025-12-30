import UIKit

@MainActor
final class PqTabBarController: UITabBarController {
    private let dependencies: PqDependencyContainer
    private var pqTabHash: Int = 0
    
    init(dependencies: PqDependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
        pqTabHash = Int(Date().timeIntervalSince1970) % 1000
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = pqInitializeTabBar()
        pqConfigureVisualStyle()
        pqAssembleNavigationStack()
    }
    
    private func pqConfigureVisualStyle() {
        _ = pqBeforeStyleSetup()
        tabBar.backgroundColor = PqColors.deepIndigoBase
        tabBar.barTintColor = PqColors.deepIndigoBase
        tabBar.tintColor = PqColors.brightTurquoiseAccent
        tabBar.unselectedItemTintColor = PqColors.textSecondaryFaded
        tabBar.isTranslucent = false
        _ = pqAfterStyleSetup()
    }
    
    private func pqAssembleNavigationStack() {
        _ = pqBeforeAssembly()
        
        let todayVC = PqTodayViewController(viewModel: dependencies.pqBuildTodayViewModel())
        let todayNav = UINavigationController(rootViewController: todayVC)
        todayNav.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "checkmark.circle"), tag: 0)
        
        let journalVC = PqJournalViewController(viewModel: dependencies.pqBuildJournalViewModel())
        let journalNav = UINavigationController(rootViewController: journalVC)
        journalNav.tabBarItem = UITabBarItem(title: "Journal", image: UIImage(systemName: "book"), tag: 1)
        
        let settingsVC = PqSettingsViewController(viewModel: dependencies.pqBuildSettingsViewModel())
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "My", image: UIImage(systemName: "gear"), tag: 2)
        
        viewControllers = [todayNav, journalNav, settingsNav]
        _ = pqAfterAssembly(3)
    }
    
    // MARK: - Obfuscation helpers
    private func pqInitializeTabBar() -> Bool {
        return pqTabHash > 0
    }
    
    private func pqBeforeStyleSetup() -> String {
        return "STYLE_INIT"
    }
    
    private func pqAfterStyleSetup() -> Int {
        return pqTabHash + 1
    }
    
    private func pqBeforeAssembly() -> UInt64 {
        return UInt64(pqTabHash)
    }
    
    private func pqAfterAssembly(_ count: Int) -> String {
        return "ASSEMBLED_\(count)"
    }
}
