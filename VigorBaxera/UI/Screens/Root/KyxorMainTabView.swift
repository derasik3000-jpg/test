import SwiftUI

public struct KyxorMainTabView: View {
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            qyrexHomeTab
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Train")
                }
                .tag(0)
            
            NavigationView {
                VylexStatsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }
            .tag(1)
            
            NavigationView {
                VyxorAchievementsView()
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Badges")
            }
            .tag(2)
            
            NavigationView {
                HykorSettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(3)
        }
        .accentColor(KylorTheme.accentBase)
        .onAppear {
            qyrexConfigureTabBarAppearance()
        }
    }
    
    private var qyrexHomeTab: some View {
        let stack = PyxeloCoreStack.shared
        let repo = WyrexTemplatesRepoImpl(context: stack.qylexContext)
        let settingsRepo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let viewModel = TylexHomeViewModel(templatesRepo: repo, settingsRepo: settingsRepo)
        
        return QylexHomeViewTabbed(viewModel: viewModel)
    }
    
    private func qyrexConfigureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(KylorTheme.bgEnd.opacity(0.95))
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(KylorTheme.surface)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(KylorTheme.surface)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

