import SwiftUI

// MARK: - Color Palette (обновлённая)
struct AppColorPalette {
    // Backgrounds
    static let bgPrimary = Color(hex: "#000000")
    static let bgSecondary = Color(hex: "#1C1C1E")
    static let bgCard = Color(hex: "#2C2C2E")
    static let bgElevated = Color(hex: "#3A3A3C")
    
    // Accents (жёлто-оранжевый)
    static let accentYellow = Color(hex: "#FFD60A")
    static let accentOrange = Color(hex: "#FF9F0A")
    static let accentGold = Color(hex: "#FFCC00")
    static let accentAmber = Color(hex: "#FF9500")
    
    // Text
    static let textPrimary = Color(hex: "#FFFFFF")
    static let textSecondary = Color(hex: "#8E8E93")
    static let textTertiary = Color(hex: "#636366")
    
    // Borders & Overlays
    static let borderSoft = Color.white.opacity(0.1)
    static let borderStrong = Color.white.opacity(0.2)
    static let glowOverlay = Color(hex: "#FF9F0A").opacity(0.15)
    
    // Gradients
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentYellow, accentOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [bgSecondary, bgPrimary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Main View
struct NimbusStageView: View {
    let url: URL?
    @StateObject private var controller = SiteCanvasController()
    @State private var showSplash = true
    @State private var minimumSplashTimeElapsed = false
    @State private var startLoadingWebView = false
    
    var body: some View {
        ZStack {
            // Background
            AppColorPalette.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar (скрыт во время загрузки)
                if !showSplash {
                    topBar
                }
                
                // WebView Content
                if startLoadingWebView {
                    SiteCanvasRepresentable(initialURL: url, controller: controller)
                        .background(AppColorPalette.bgPrimary)
                        .opacity(showSplash ? 0 : 1)
                } else {
                    AppColorPalette.bgPrimary
                }
            }
            
            // Premium Splash Overlay с анимациями
            if showSplash {
                PremiumSplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .statusBarHidden(showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startLoadingWebView = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                minimumSplashTimeElapsed = true
                checkAndHideSplash()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                forcedHideSplash()
            }
        }
        .onChange(of: controller.hasError) { hasError in
            if hasError {
                forcedHideSplash()
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 8) {
            // Navigation Buttons Group
            HStack(spacing: 4) {
                NavButton(
                    icon: "chevron.left",
                    isEnabled: controller.canNavigateBack,
                    action: { controller.goBack() }
                )
                
                NavButton(
                    icon: "chevron.right",
                    isEnabled: controller.canNavigateForward,
                    action: { controller.goForward() }
                )
            }
            .padding(4)
            .background(AppColorPalette.bgCard)
            .cornerRadius(12)
            
            Spacer()
            
            // Reload Button
            NavButton(
                icon: "arrow.clockwise",
                isEnabled: true,
                action: { controller.reload() }
            )
            .padding(4)
            .background(AppColorPalette.bgCard)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            AppColorPalette.bgSecondary
                .overlay(
                    Rectangle()
                        .fill(AppColorPalette.borderSoft)
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
    
    private func checkAndHideSplash() {
        if minimumSplashTimeElapsed && showSplash {
            withAnimation(.easeOut(duration: 0.6)) {
                showSplash = false
            }
        }
    }
    
    private func forcedHideSplash() {
        if showSplash {
            withAnimation(.easeOut(duration: 0.6)) {
                showSplash = false
            }
        }
    }
}

// MARK: - Navigation Button
struct NavButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? AppColorPalette.textPrimary : AppColorPalette.textTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled)
        .buttonStyle(NavButtonStyle(isEnabled: isEnabled))
    }
}

struct NavButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed && isEnabled
                    ? AppColorPalette.bgElevated
                    : Color.clear
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Premium Splash View
struct PremiumSplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var particlesOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedGradientBackground()
            
            // Floating Particles
            ParticlesView()
                .opacity(particlesOpacity)
            
            // Content
            VStack(spacing: 48) {
                Spacer()
                
                // Logo with animated rings
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    AppColorPalette.accentYellow.opacity(0.6),
                                    AppColorPalette.accentOrange.opacity(0.3),
                                    AppColorPalette.accentYellow.opacity(0.1),
                                    AppColorPalette.accentOrange.opacity(0.3),
                                    AppColorPalette.accentYellow.opacity(0.6)
                                ],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(ringRotation))
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            AppColorPalette.accentGradient,
                            lineWidth: 3
                        )
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(-ringRotation * 0.7))
                    
                    // Inner filled circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColorPalette.accentYellow,
                                    AppColorPalette.accentOrange,
                                    AppColorPalette.accentAmber
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 45
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: AppColorPalette.accentOrange.opacity(0.6), radius: 30, y: 10)
                    
                    // Icon
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App name with subtle animation
                Text("Nimbus")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColorPalette.textPrimary)
                    .opacity(textOpacity)
                    .scaleEffect(textOpacity > 0 ? 1.0 : 0.9)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: textOpacity)
                
                Spacer()
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            textOpacity = 1.0
        }
        
        // Particles fade in
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            particlesOpacity = 1.0
        }
        
        // Continuous ring rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base dark background
            AppColorPalette.bgPrimary
            
            // Animated gradient blobs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColorPalette.accentOrange.opacity(0.3),
                            AppColorPalette.accentOrange.opacity(0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animateGradient ? 50 : -50, y: animateGradient ? -100 : -150)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColorPalette.accentYellow.opacity(0.2),
                            AppColorPalette.accentYellow.opacity(0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: animateGradient ? -80 : -30, y: animateGradient ? 200 : 250)
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Floating Particles
struct ParticlesView: View {
    @State private var particles: [FloatingParticle] = []
    
    struct FloatingParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColorPalette.accentYellow.opacity(particle.opacity),
                                    AppColorPalette.accentOrange.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size / 2
                            )
                        )
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<25).map { _ in
            FloatingParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 4...16),
                opacity: Double.random(in: 0.2...0.6),
                speed: Double.random(in: 3...7)
            )
        }
        
        // Animate particles
        for index in particles.indices {
            let particle = particles[index]
            withAnimation(
                .easeInOut(duration: particle.speed)
                .repeatForever(autoreverses: true)
            ) {
                particles[index].y += CGFloat.random(in: -50...50)
                particles[index].x += CGFloat.random(in: -30...30)
            }
        }
    }
}
