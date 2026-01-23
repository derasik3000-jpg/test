import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView(viewModel: AppDependencies.shared.makeHomeViewModel())
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            StatisticsView(viewModel: AppDependencies.shared.makeStatisticsViewModel())
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            ArchiveView(viewModel: AppDependencies.shared.makeArchiveViewModel())
                .tabItem {
                    Label("Archive", systemImage: "archivebox.fill")
                }
            
            SettingsView(viewModel: AppDependencies.shared.makeSettingsViewModel())
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(ColorTheme.Accent.accent500)
    }
}

