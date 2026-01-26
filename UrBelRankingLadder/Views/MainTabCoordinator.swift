import SwiftUI

// MARK: - Tab Item Model
enum MainTab: Int, CaseIterable {
    case plate
    case templates
    case daySummary
    
    var title: String {
        switch self {
        case .plate: return "Plate"
        case .templates: return "Templates"
        case .daySummary: return "Day"
        }
    }
    
    var icon: String {
        switch self {
        case .plate: return "fork.knife.circle"
        case .templates: return "square.grid.2x2"
        case .daySummary: return "chart.bar.fill"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .plate: return "fork.knife.circle.fill"
        case .templates: return "square.grid.2x2.fill"
        case .daySummary: return "chart.bar.fill"
        }
    }
}

// MARK: - Main Coordinator
struct MainTabCoordinator: View {
    @State private var selectedTab: MainTab = .plate
    
    @StateObject private var plateViewModel = DependencyContainer.shared.makePlateViewModel()
    @StateObject private var ingredientsViewModel = DependencyContainer.shared.makeIngredientsViewModel()
    @StateObject private var templateViewModel = DependencyContainer.shared.makeTemplateViewModel()
    @StateObject private var daySummaryViewModel = DependencyContainer.shared.makeDaySummaryViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .plate:
                    PlateConstructorScreen(
                        viewModel: plateViewModel,
                        ingredientsViewModel: ingredientsViewModel,
                        templateViewModel: templateViewModel
                    )
                case .templates:
                    TemplateLibraryScreen(viewModel: templateViewModel)
                case .daySummary:
                    DaySummaryScreen(viewModel: daySummaryViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            TabBarBackground()
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: MainTab
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appAccentYellow.opacity(0.2),
                                        Color.appAccentOrange.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 36)
                            .matchedGeometryEffect(id: "TAB_BG", in: animation)
                    }
                    
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                            ? AnyShapeStyle(LinearGradient(
                                colors: [.appAccentYellow, .appAccentOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(Color.appTextSecondary)
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(height: 36)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .appAccentYellow : .appTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabButtonStyle())
    }
}

// MARK: - Tab Bar Background
struct TabBarBackground: View {
    var body: some View {
        ZStack {
            // Blur effect
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            
            // Border gradient
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            // Inner shadow/glow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appCardBackground.opacity(0.8),
                            Color.appBackgroundSecondary.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(1)
        }
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
        .padding(.horizontal, 16)
    }
}

// MARK: - Button Style
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
