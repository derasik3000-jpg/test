import SwiftUI

struct EnhancedTabBar: View {
    let selectedTab: TabSelection
    let isDark: Bool
    let onTabSelected: (TabSelection) -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            NavigationTabButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == .home,
                isDark: isDark
            ) {
                onTabSelected(.home)
            }
            
            NavigationTabButton(
                icon: "moon.fill",
                title: "Diary",
                isSelected: selectedTab == .diary,
                isDark: isDark
            ) {
                onTabSelected(.diary)
            }
            
            NavigationTabButton(
                icon: "chart.bar.fill",
                title: "Stats",
                isSelected: selectedTab == .stats,
                isDark: isDark
            ) {
                onTabSelected(.stats)
            }
            
            NavigationTabButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == .settings,
                isDark: isDark
            ) {
                onTabSelected(.settings)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                // Глянцевый эффект
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.adaptiveCard(isDark).opacity(0.95))
                
                // Градиент сверху для глубины
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.adaptiveAccent(isDark).opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Тонкая рамка
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(
                        Color.adaptiveAccent(isDark).opacity(0.1),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.adaptiveText(isDark).opacity(0.08), radius: 20, x: 0, y: -5)
        .shadow(color: Color.adaptiveAccent(isDark).opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

enum TabSelection {
    case home
    case diary
    case stats
    case settings
}

