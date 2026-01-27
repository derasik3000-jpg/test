import SwiftUI

// MARK: - Main Stage View

struct NimbusStageView: View {
    let url: URL?
    @StateObject private var controller = SiteCanvasController()
    @State private var showSplash = true
    @State private var minimumSplashTimeElapsed = false
    @State private var startLoadingWebView = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundDeep
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                if startLoadingWebView {
                    SiteCanvasRepresentable(initialURL: url, controller: controller)
                        .background(AppTheme.backgroundDeep)
                        .opacity(showSplash ? 0 : 1)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    AppTheme.backgroundDeep
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            
            PremiumSplashView()
                .opacity(showSplash ? 1 : 0)
                .allowsHitTesting(showSplash)
                .zIndex(1)
        }
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
        .onChange(of: controller.loadingProgress) { newProgress in
            if newProgress >= 0.90 {
                checkAndHideSplash()
            }
        }
        .onChange(of: controller.hasError) { hasError in
            if hasError {
                forcedHideSplash()
            }
        }
    }
    
    private func checkAndHideSplash() {
        if minimumSplashTimeElapsed && controller.loadingProgress >= 0.90 && showSplash {
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
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 12) {
            NavigationButton(
                icon: "chevron.left",
                isEnabled: controller.canNavigateBack,
                action: { controller.goBack() }
            )
            
            NavigationButton(
                icon: "chevron.right",
                isEnabled: controller.canNavigateForward,
                action: { controller.goForward() }
            )
            
            Spacer(minLength: 0)
            
            if controller.isLoading {
                LoadingIndicator()
            }
            
            NavigationButton(
                icon: "arrow.clockwise",
                isEnabled: true,
                action: { controller.reload() }
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            AppTheme.surfaceDark
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.goldDark.opacity(0.1), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
}

// MARK: - Navigation Button

struct NavigationButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isEnabled ? AppTheme.goldPrimary : AppTheme.textMuted)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.backgroundElevated)
                        .overlay(
                            Circle()
                                .stroke(
                                    isEnabled ? AppTheme.goldDark.opacity(0.3) : AppTheme.dividerTint,
                                    lineWidth: 1
                                )
                        )
                )
                .contentShape(Circle())
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Loading Indicator

struct LoadingIndicator: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [AppTheme.goldDark, AppTheme.goldPrimary, AppTheme.goldLight],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Premium Splash View

struct PremiumSplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundDeep
                .ignoresSafeArea()
            
            // Animated particles
            GoldParticlesView()
            
            // Ambient glow
            RadialGradient(
                colors: [
                    AppTheme.goldDark.opacity(0.15),
                    AppTheme.goldDark.opacity(0.05),
                    .clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Logo with effects
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(
                            AppTheme.goldGradient,
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                    
                    // Main hexagon
                    ZStack {
                        // Glow behind
                        PolygonShape(sides: 6, rotation: .degrees(-30))
                            .fill(AppTheme.goldPrimary)
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                            .opacity(0.4)
                        
                        // Main shape with gradient
                        PolygonShape(sides: 6, rotation: .degrees(-30))
                            .fill(AppTheme.goldGradient)
                            .frame(width: 72, height: 72)
                            .overlay(
                                PolygonShape(sides: 6, rotation: .degrees(-30))
                                    .stroke(AppTheme.goldLight.opacity(0.5), lineWidth: 1)
                            )
                        
                        // Inner icon
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.backgroundDeep)
                        
                        // Shimmer effect
                        PolygonShape(sides: 6, rotation: .degrees(-30))
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        AppTheme.goldLight.opacity(0.4),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .offset(x: shimmerOffset)
                            .mask(
                                PolygonShape(sides: 6, rotation: .degrees(-30))
                                    .frame(width: 72, height: 72)
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }
                
                // Loading text
                VStack(spacing: 12) {
                    Text("Loading")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    // Progress dots
                    LoadingDots()
                }
                .opacity(textOpacity)
            }
        }
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
        
        // Ring pulse
        withAnimation(.easeOut(duration: 1.2).delay(0.4)) {
            ringScale = 1.3
            ringOpacity = 0.6
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
            ringOpacity = 0
        }
        
        // Text fade in
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            textOpacity = 1.0
        }
        
        // Shimmer loop
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(0.8)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Loading Dots

struct LoadingDots: View {
    @State private var activeIndex = 0
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index == activeIndex ? AppTheme.goldPrimary : AppTheme.goldDark.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .scaleEffect(index == activeIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: activeIndex)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                activeIndex = (activeIndex + 1) % 3
            }
        }
    }
}

// MARK: - Gold Particles

struct GoldParticlesView: View {
    @State private var particles: [GoldParticle] = []
    
    struct GoldParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var delay: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [AppTheme.goldLight, AppTheme.goldPrimary.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size
                            )
                        )
                        .frame(width: particle.size * 2, height: particle.size * 2)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        particles = (0..<15).map { i in
            GoldParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.2...0.5),
                delay: Double(i) * 0.1
            )
        }
        
        animateParticles(in: size)
    }
    
    private func animateParticles(in size: CGSize) {
        for index in particles.indices {
            let particle = particles[index]
            withAnimation(
                .easeInOut(duration: Double.random(in: 3...6))
                .repeatForever(autoreverses: true)
                .delay(particle.delay)
            ) {
                particles[index].y = CGFloat.random(in: 0...size.height)
                particles[index].opacity = Double.random(in: 0.1...0.4)
            }
        }
    }
}

// MARK: - Polygon Shape

struct PolygonShape: Shape {
    var sides: Int
    var rotation: Angle = .zero
    
    func path(in rect: CGRect) -> Path {
        guard sides > 2 else { return Path() }
        
        let angle = .pi * 2 / CGFloat(sides)
        let radius = min(rect.size.width, rect.size.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        var path = Path()
        
        for i in 0..<sides {
            let x = center.x + radius * cos(angle * CGFloat(i) + CGFloat(rotation.radians) - .pi / 2)
            let y = center.y + radius * sin(angle * CGFloat(i) + CGFloat(rotation.radians) - .pi / 2)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}
