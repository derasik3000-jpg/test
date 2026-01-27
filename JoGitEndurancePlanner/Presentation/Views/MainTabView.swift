import SwiftUI

// MARK: - Tab Item Model

enum AppTab: Int, CaseIterable {
    case week, month, rules
    
    var title: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .rules: return "Rules"
        }
    }
    
    var icon: String {
        switch self {
        case .week: return "calendar.badge.clock"
        case .month: return "calendar"
        case .rules: return "slider.horizontal.3"
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: AppTab = .week
    
    @StateObject private var spanViewModel: SpanViewModel
    @StateObject private var archiveViewModel: ArchiveViewModel
    @StateObject private var blueprintViewModel: BlueprintViewModel
    
    init() {
        let clock = SystemClockProvider()
        let haptics = HapticFeedbackService()
        let bounceVault = BounceVaultRepository(clockProvider: clock)
        let metricsVault = MetricsVaultRepository(bounceVault: bounceVault)
        
        _spanViewModel = StateObject(wrappedValue: SpanViewModel(
            bounceVault: bounceVault,
            metricsVault: metricsVault,
            clockProvider: clock,
            haptics: haptics
        ))
        
        _archiveViewModel = StateObject(wrappedValue: ArchiveViewModel(
            bounceVault: bounceVault,
            metricsVault: metricsVault,
            clockProvider: clock
        ))
        
        _blueprintViewModel = StateObject(wrappedValue: BlueprintViewModel(
            bounceVault: bounceVault,
            haptics: haptics
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            AppTheme.backgroundDeep
                .ignoresSafeArea()
            
            // Content
            Group {
                switch selectedTab {
                case .week:
                    SpanTabView(viewModel: spanViewModel)
                case .month:
                    ArchiveTabView(viewModel: archiveViewModel)
                case .rules:
                    BlueprintTabView(viewModel: blueprintViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var tabAnimation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: tabAnimation
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.goldPrimary.opacity(0.15))
                            .matchedGeometryEffect(id: "tabBackground", in: namespace)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? AppTheme.goldPrimary : AppTheme.textMuted)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(width: 56, height: 36)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppTheme.goldLight : AppTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabButtonStyle())
    }
}

// MARK: - Button Style

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
