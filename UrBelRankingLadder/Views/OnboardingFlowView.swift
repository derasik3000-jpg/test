import SwiftUI

// MARK: - Onboarding Flow
struct OnboardingFlowView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "chart.pie.fill",
            title: "3:2:1 Balance",
            description: "Build balanced meals with 3 parts vegetables, 2 parts protein, and 1 part carbs",
            accentColor: .appAccentYellow
        ),
        OnboardingPage(
            icon: "hand.tap.fill",
            title: "Quick & Easy",
            description: "Tap to add full portions, long press for half portions",
            accentColor: .appAccentOrange
        ),
        OnboardingPage(
            icon: "star.circle.fill",
            title: "Earn Gold Badge",
            description: "Achieve perfect balance to earn your daily gold badge",
            accentColor: .appAccentGold
        ),
        OnboardingPage(
            icon: "doc.plaintext.fill",
            title: "Offline First",
            description: "Works completely offline. Export your data anytime",
            accentColor: .appAccentYellow
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                AnimatedOnboardingBackground(currentPage: currentPage)
                
                VStack(spacing: 0) {
                    // Skip Button
                    HStack {
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                coordinator.completeOnboarding()
                            }) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appTextSecondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    .frame(height: 44)
                    
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            OnboardingPageView(
                                page: pages[index],
                                pageIndex: index,
                                currentPage: currentPage,
                                screenWidth: geometry.size.width
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Bottom Section
                    VStack(spacing: 24) {
                        // Custom Page Indicator
                        PageIndicator(
                            totalPages: pages.count,
                            currentPage: currentPage
                        )
                        
                        // Action Button
                        OnboardingButton(
                            title: currentPage == pages.count - 1 ? "Get Started" : "Continue",
                            isLastPage: currentPage == pages.count - 1
                        ) {
                            if currentPage < pages.count - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            } else {
                                coordinator.completeOnboarding()
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Animated Background
struct AnimatedOnboardingBackground: View {
    let currentPage: Int
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base
            Color.appBackground.ignoresSafeArea()
            
            // Gradient Orbs - more subtle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccentOrange.opacity(0.15),
                            Color.appAccentOrange.opacity(0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 80, y: -150)
                .blur(radius: 50)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccentYellow.opacity(0.12),
                            Color.appAccentYellow.opacity(0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: -80, y: 250)
                .blur(radius: 40)
        }
    }
}

// Removed FloatingParticlesView - simplified background

// MARK: - Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let currentPage: Int
    let screenWidth: CGFloat
    
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    private var isActive: Bool {
        pageIndex == currentPage
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated Icon
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.accentColor.opacity(0.25),
                                page.accentColor.opacity(0)
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 90
                        )
                    )
                    .frame(width: 160, height: 160)
                
                // Icon container
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                page.accentColor,
                                page.accentColor.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: page.accentColor.opacity(0.4), radius: 20, y: 8)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.black)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Text Content
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: min(screenWidth - 80, 400))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(textOpacity)
            .padding(.horizontal, 24)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onChange(of: currentPage) { newPage in
            if pageIndex == newPage {
                animateIn()
            }
        }
        .onAppear {
            if isActive {
                // Small delay to ensure view is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animateIn()
                }
            }
        }
    }
    
    private func animateIn() {
        // Reset first
        iconScale = 0.8
        iconOpacity = 0
        textOpacity = 0
        
        // Animate icon
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        // Animate text
        withAnimation(.easeOut(duration: 0.4).delay( 0.25)) {
            textOpacity = 1.0
        }
    }
}

// MARK: - Page Indicator
struct PageIndicator: View {
    let totalPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(LinearGradient(
                                colors: [.appAccentYellow, .appAccentOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            : AnyShapeStyle(Color.appTextTertiary.opacity(0.5))
                    )
                    .frame(
                        width: index == currentPage ? 24 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
            }
        }
    }
}

// MARK: - Onboarding Button
struct OnboardingButton: View {
    let title: String
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                if isLastPage {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [.appAccentYellow, .appAccentOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .appAccentOrange.opacity(0.3), radius: 12, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Removed ShimmerView - simplified button


