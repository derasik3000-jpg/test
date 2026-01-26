import SwiftUI

public struct NavigationHubLayout: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Content - full screen
            Group {
                switch selectedTab {
                case 0:
                    CheckTabView()
                case 1:
                    RecordBrowserView(
                        viewModel: ProvisionRegistry.shared.historyVM
                    )
                case 2:
                    LibraryTabView(
                        viewModel: ProvisionRegistry.shared.libraryVM
                    )
                default:
                    CheckTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, namespace: animation)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var namespace: Namespace.ID
    
    @State private var tabBarOffset: CGFloat = 100
    
    private let tabs: [TabItem] = [
        TabItem(icon: "heart.text.square.fill", title: "Check", tag: 0),
        TabItem(icon: "clock.fill", title: "History", tag: 1),
        TabItem(icon: "book.fill", title: "Library", tag: 2)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.tag,
                    namespace: namespace,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedTab = tab.tag
                        }
                        
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(
            TabBarBackground()
        )
        .padding(.horizontal, 16)
        .offset(y: tabBarOffset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                tabBarOffset = 0
            }
        }
    }
}

// MARK: - Tab Bar Background

struct TabBarBackground: View {
    var body: some View {
        ZStack {
            // Solid background with blur
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
            
            // Dark background for better visibility
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [
                            ThemeColorsConfig.backgroundCard.opacity(0.95),
                            ThemeColorsConfig.backgroundDeep.opacity(0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Vibrant gradient border
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColorsConfig.accentBright.opacity(0.5),
                            ThemeColorsConfig.accentBright.opacity(0.2),
                            ThemeColorsConfig.accentWarm.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            // Top highlight glow
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [
                            ThemeColorsConfig.accentBright.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
        }
        .shadow(color: ThemeColorsConfig.accentBright.opacity(0.15), radius: 20, x: 0, y: -5)
        .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: -10)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Animated background for selected state
                    if isSelected {
                        // Outer glow ring
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ThemeColorsConfig.accentBright.opacity(0.3),
                                        ThemeColorsConfig.accentBright.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 35
                                )
                            )
                            .frame(width: 70, height: 70)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .opacity(pulseAnimation ? 0.6 : 1.0)
                        
                        // Main background capsule
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ThemeColorsConfig.accentBright.opacity(0.3),
                                        ThemeColorsConfig.accentBright.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                ThemeColorsConfig.accentBright.opacity(0.6),
                                                ThemeColorsConfig.accentBright.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: ThemeColorsConfig.accentBright.opacity(0.4), radius: 12, x: 0, y: 4)
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                    }
                    
                    // Icon with enhanced effects
                    ZStack {
                        // Icon glow background
                        if isSelected {
                            Circle()
                                .fill(ThemeColorsConfig.accentBright.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .blur(radius: 4)
                        }
                        
                        Image(systemName: tab.icon)
                            .font(.system(size: isSelected ? 24 : 22, weight: .semibold))
                            .foregroundStyle(
                                isSelected ?
                                LinearGradient(
                                    colors: [
                                        ThemeColorsConfig.accentBright,
                                        ThemeColorsConfig.accentBright.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [
                                        ThemeColorsConfig.neutralAxis.opacity(0.6),
                                        ThemeColorsConfig.neutralAxis.opacity(0.6)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .shadow(
                                color: isSelected ? ThemeColorsConfig.accentBright.opacity(0.6) : .clear,
                                radius: isSelected ? 8 : 0,
                                x: 0,
                                y: isSelected ? 2 : 0
                            )
                    }
                }
                .frame(height: 44)
                
                // Label with gradient when selected
                Text(tab.title)
                    .font(.system(size: isSelected ? 12 : 11, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                ThemeColorsConfig.accentBright,
                                ThemeColorsConfig.accentBright.opacity(0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [
                                ThemeColorsConfig.neutralAxis.opacity(0.6),
                                ThemeColorsConfig.neutralAxis.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(
                        color: isSelected ? ThemeColorsConfig.accentBright.opacity(0.3) : .clear,
                        radius: isSelected ? 4 : 0
                    )
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.90 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onAppear {
            if isSelected {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

// MARK: - Tab Item Model

struct TabItem {
    let icon: String
    let title: String
    let tag: Int
}

