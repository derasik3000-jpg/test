import SwiftUI

@main
struct IPYourTierApp: App {
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ApplicationEntryPoint()
                .preferredColorScheme(.dark)
        }
    }
    
    private func setupAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(ThemeColorsConfig.primaryLight)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(ThemeColorsConfig.primaryLight)]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(ThemeColorsConfig.primaryLight)
    }
}
