import SwiftUI

struct CuqavuMainTabView: View {
    @State private var selectedTab: Tab = .home
    @ObservedObject var themeManager = CuqavuThemeManager.shared
    @StateObject private var homeViewModel = DegubaHomeViewModel()
    
    enum Tab {
        case home
        case history
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EvubewHomeView()
                .environmentObject(homeViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            AxemobHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
        }
        .tint(themeManager.degubaCurrentTheme.evubewPrimary)
    }
}

#Preview {
    CuqavuMainTabView()
        .preferredColorScheme(.dark)
}
