import SwiftUI

struct PrimaryTabInterface: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SpheresHomeView()
                .tabItem {
                    Label("Spheres", systemImage: "square.grid.2x2")
                }
                .tag(0)
            
            RadarView()
                .tabItem {
                    Label("Radar", systemImage: "chart.pie")
                }
                .tag(1)
            
            ChronologicalDisplay()
                .tabItem {
                    Label("Timeline", systemImage: "clock")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .accentColor(AuroraThemeColors.pureWhite)
    }
}

