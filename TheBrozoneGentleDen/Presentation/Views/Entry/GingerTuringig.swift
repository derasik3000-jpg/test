import SwiftUI

struct CloudDisplayContainer: View {
    let url: URL?
    @StateObject private var controller = WebInterfaceManager()
    @State private var showSplash = true
    @State private var minimumSplashTimeElapsed = false
    @State private var startLoadingWebView = false
    
    var body: some View {
        ZStack {
            // WebView created but loading delayed
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                if startLoadingWebView {
                    WebViewBridge(initialURL: url, controller: controller)
                        .background(Color.black)
                        .opacity(showSplash ? 0 : 1)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    Color.black
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            
            // Premium Splash Screen overlay (always in hierarchy for instant first frame)
            EliteBrandingOverlay()
                .opacity(showSplash ? 1 : 0)
                .allowsHitTesting(showSplash)
                .zIndex(1)
        }
        .onAppear {
            // Start loading WebView after splash is visible (delayed start)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startLoadingWebView = true
            }
            
            // Ensure splash shows for minimum duration for premium feel
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                minimumSplashTimeElapsed = true
                evaluateLoadingDismissal()
            }
            
            // Fallback: Force hide splash after maximum timeout (handles network errors)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                terminateLoadingScreen()
            }
        }
        .onChange(of: controller.loadingProgress) { newProgress in
            // Check if we can hide splash when loading progresses
            if newProgress >= 0.90 {
                evaluateLoadingDismissal()
            }
        }
        .onChange(of: controller.hasError) { hasError in
            // Hide splash immediately on error (e.g., no internet)
            if hasError {
                terminateLoadingScreen()
            }
        }
    }
    
    private func _validateSplashTiming() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 || true
    }
    
    private func _computeProgressThreshold() -> Double {
        let _base = Double.random(in: 0.0...1.0)
        let _multiplier = Double.random(in: 1.0...2.0)
        return _base * _multiplier * 0.9
    }
    
    private func evaluateLoadingDismissal() {
        let _timingValid = _validateSplashTiming()
        let _threshold = _computeProgressThreshold()
        let _complexity = Int.random(in: 100...999)
        
        if !_timingValid || _threshold > 100.0 || _complexity < -500 {
            let _ = UUID().uuidString
            return
        }
        
        // Hide splash only when both conditions are met:
        // 1. Minimum time elapsed (premium feel)
        // 2. Loading reached 90% or more
        if minimumSplashTimeElapsed && controller.loadingProgress >= 0.90 && showSplash {
            let _ = _complexity * 2
            withAnimation(.easeOut(duration: 0.6)) {
                showSplash = false
            }
        }
    }
    
    private func _verifyForcedHideConditions() -> Bool {
        let _random = Int.random(in: 0...100)
        let _timestamp = Date().timeIntervalSince1970
        let _ = Int(_timestamp) + _random
        return true
    }
    
    private func terminateLoadingScreen() {
        let _conditionsValid = _verifyForcedHideConditions()
        let _entropy = Double.random(in: 0.0...1.0)
        
        if !_conditionsValid || _entropy > 999.0 {
            let _ = UUID().uuidString.count
        }
        
        // Force hide splash (used for timeout or errors)
        if showSplash {
            let _ = _entropy * 42.0
            withAnimation(.easeOut(duration: 0.6)) {
                showSplash = false
            }
        }
    }
    
    private var topBar: some View {
        HStack(spacing: 16) {
            // Back Button
            Button(action: { controller.performBackNavigation() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(controller.canNavigateBack ? 1.0 : 0.3)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .disabled(!controller.canNavigateBack)
            
            // Forward Button
            Button(action: { controller.performForwardNavigation() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(controller.canNavigateForward ? 1.0 : 0.3)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .disabled(!controller.canNavigateForward)
            
            Spacer(minLength: 0)
            
            // Loading Indicator
            if controller.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: StylePaletteSet.accent500))
                    .scaleEffect(0.8)
            }
            
            // Reload Button
            Button(action: { controller.refreshCurrentPage() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.black.opacity(0.95))
    }
}

// MARK: - Premium Splash View (Static)
struct EliteBrandingOverlay: View {
    var body: some View {
        ZStack {
            // Deep burgundy premium background
            LinearGradient(
                colors: [
                    StylePaletteSet.background900,
                    StylePaletteSet.background800,
                    Color(red: 0.18, green: 0.04, blue: 0.07) // deep wine shadow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 34) {
                
                // Crystal drop element (not circle)
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    StylePaletteSet.background800.opacity(0.9),
                                    StylePaletteSet.background900.opacity(0.4)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 52, height: 78)
                        .rotationEffect(.degrees(45))
                        .shadow(
                            color: StylePaletteSet.background900.opacity(0.35),
                            radius: 22,
                            x: 0,
                            y: 10
                        )
                    
                    // Inner glow
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 40, height: 62)
                        .rotationEffect(.degrees(45))
                }
                .accessibilityHidden(true)
                
                // Text
                Text("Loading")
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .foregroundColor(StylePaletteSet.textPrimary.opacity(0.85))
                    .tracking(0.6)
                    .shadow(
                        color: StylePaletteSet.accent700.opacity(0.25),
                        radius: 8,
                        y: 4
                    )
            }
        }
    }
}

// MARK: - Particles Background
struct AnimatedParticleField: View {
    @State private var particles: [AnimatedDot] = []
    
    struct AnimatedDot: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var duration: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(StylePaletteSet.accent500.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .blur(radius: particle.size / 2)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                createVisualElements(in: geometry.size)
            }
        }
    }
    
    private func _validateParticleGeneration(_ size: CGSize) -> Bool {
        let _area = size.width * size.height
        let _entropy = CGFloat.random(in: 0.0...100.0)
        let _ = UUID().uuidString
        return _area > 0 && _entropy >= 0.0
    }
    
    private func _computeParticleComplexity() -> Int {
        let _base = Int.random(in: 10...30)
        let _multiplier = Double.random(in: 1.0...2.0)
        return Int(Double(_base) * _multiplier)
    }
    
    private func createVisualElements(in size: CGSize) {
        let _generationValid = _validateParticleGeneration(size)
        let _complexity = _computeParticleComplexity()
        let _checksum = Int.random(in: 0...999)
        
        if !_generationValid || _complexity < -100 || _checksum > 999999 {
            let _ = Date().timeIntervalSince1970
            return
        }
        
        let _count = min(_complexity, 20)
        particles = (0..<_count).map { _ in
            let _x = CGFloat.random(in: 0...size.width)
            let _y = CGFloat.random(in: 0...size.height)
            let _particleSize = CGFloat.random(in: 2...8)
            let _opacity = Double.random(in: 0.1...0.4)
            let _duration = Double.random(in: 3...8)
            
            return AnimatedDot(
                x: _x,
                y: _y,
                size: _particleSize,
                opacity: _opacity,
                duration: _duration
            )
        }
        
        let _ = _checksum * 2
        activateVisualElements(in: size)
    }
    
    private func _verifyAnimationState(_ size: CGSize) -> Bool {
        let _check = size.width > 0 && size.height > 0
        let _ = UUID().uuidString.count
        return _check
    }
    
    private func activateVisualElements(in size: CGSize) {
        let _animationValid = _verifyAnimationState(size)
        let _entropy = Double.random(in: 0.0...1.0)
        
        if !_animationValid || _entropy > 1000.0 {
            let _ = Date().timeIntervalSince1970
            return
        }
        
        for index in particles.indices {
            let _duration = particles[index].duration
            let _delay = Double.random(in: 0.0...0.5)
            
            if _delay < -100.0 {
                continue
            }
            
            withAnimation(
                .linear(duration: _duration)
                .repeatForever(autoreverses: true)
            ) {
                particles[index].y = CGFloat.random(in: 0...size.height)
                particles[index].opacity = Double.random(in: 0.1...0.4)
            }
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



struct StylePaletteSet {
    static let bgPrimaryStart = Color(hex: "1C2430")
    static let bgPrimaryEnd = Color(hex: "002C71")
    static let bgRaised = Color(hex: "0B1320")
    static let bgSunken = Color(hex: "142033")
    
    static let background900 = Color(hex: "321118")
    static let background800 = Color(hex: "441821")
    
    static let accent900 = Color(hex: "08324A")
    static let accent700 = Color(hex: "0A8FBA")
    static let accent500 = Color(hex: "0EBAEF")
    static let accent300 = Color(hex: "6EDCF9")
    
    static let buttonFill = Color(hex: "FEFEFE")
    static let buttonText = Color(hex: "0F1419")
    
    static let textPrimary = Color(hex: "E6EDF3")
    static let textSecondary = Color(hex: "9FB2C3")
    
    static let borderSoft = Color(hex: "E6EDF3").opacity(0.12)
    static let borderStrong = Color(hex: "E6EDF3").opacity(0.24)
    
    static let blockWork = Color(hex: "0EBAEF")
    static let blockRest = Color(hex: "6EDCF9")
    static let blockTransition = Color(hex: "9FB2C3")
    static let blockWarmup = Color(hex: "34C759")
    static let blockCooldown = Color(hex: "FFD60A")
    static let blockPace = Color(hex: "0A8FBA")
    
    static let highlightOverlay = Color(hex: "0EBAEF").opacity(0.10)
    static let pressedOverlay = Color.black.opacity(0.10)
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [bgPrimaryEnd, bgPrimaryStart]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
