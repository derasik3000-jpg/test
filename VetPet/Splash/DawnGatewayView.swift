import SwiftUI

// MARK: - DawnGatewayView
// Animated launch screen with pulsing paw icon,
// golden ring, particle burst, and abstract loading texts

struct DawnGatewayView: View {

    let onFinished: () -> Void

    @State private var pawScale: CGFloat = 0.3
    @State private var pawOpacity: Double = 0.0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.0
    @State private var ringRotation: Double = 0.0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOpacity: Double = 0.0
    @State private var loadingDots: Int = 0
    @State private var particlesVisible: Bool = false
    @State private var phaseIndex: Int = 0
    @State private var fadeOut: Double = 1.0

    private let loadingPhrases = [
        "Awakening senses…",
        "Tuning into wellness…",
        "Preparing your sanctuary…",
        "Aligning vital signs…",
        "Almost there…"
    ]

    var body: some View {
        ZStack {
            // Animated background
            EmberCanvasView()
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Golden ring behind paw
                goldenRingLayer

                // App title
                titleBlock

                Spacer()

                // Loading text
                loadingBlock

                Spacer()
                    .frame(height: 60)
            }
        }
        .opacity(fadeOut)
        .onAppear(perform: startSequence)
    }

    // MARK: - Golden Ring + Paw

    private var goldenRingLayer: some View {
        ZStack {
            // Outer spinning ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            AuraPalette.lifeGold,
                            AuraPalette.lifeGold.opacity(0.2),
                            AuraPalette.amberPulse,
                            AuraPalette.lifeGold
                        ],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 140, height: 140)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .rotationEffect(.degrees(ringRotation))

            // Inner glow circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AuraPalette.lifeGold.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 70
                    )
                )
                .frame(width: 130, height: 130)
                .opacity(ringOpacity)

            // Paw icon
            Text("🐾")
                .font(.system(size: 64))
                .scaleEffect(pawScale)
                .opacity(pawOpacity)

            // Particle dots
            if particlesVisible {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(AuraPalette.lifeGold)
                        .frame(width: 4, height: 4)
                        .offset(y: -80)
                        .rotationEffect(.degrees(Double(i) * 45))
                        .opacity(Double.random(in: 0.3...0.8))
                        .scaleEffect(Double.random(in: 0.6...1.2))
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("Pet Log: True Feel")
                .font(AuraFont.heroTitle())
                .foregroundColor(AuraPalette.boneWhite)
                .offset(y: titleOffset)
                .opacity(titleOpacity)

            Text("observe · track · protect")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)
                .tracking(2)
                .opacity(subtitleOpacity)
        }
    }

    // MARK: - Loading

    private var loadingBlock: some View {
        VStack(spacing: 12) {
            // Dots indicator
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { dot in
                    Circle()
                        .fill(
                            dot <= loadingDots
                            ? AuraPalette.lifeGold
                            : AuraPalette.whisperAsh
                        )
                        .frame(width: 6, height: 6)
                        .scaleEffect(dot <= loadingDots ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4).delay(Double(dot) * 0.15),
                            value: loadingDots
                        )
                }
            }

            // Rotating phrases
            Text(loadingPhrases[phaseIndex])
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.whisperAsh)
                .animation(.easeInOut(duration: 0.5), value: phaseIndex)
        }
    }

    // MARK: - Animation Sequence

    private func startSequence() {
        // Phase 1: Paw appears (0.0s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            pawScale = 1.0
            pawOpacity = 1.0
        }

        // Phase 2: Ring expands (0.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }

        // Phase 3: Title slides up (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }

        // Phase 4: Subtitle (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.6)) {
                subtitleOpacity = 1.0
            }
        }

        // Phase 5: Particles burst (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                particlesVisible = true
            }
        }

        // Phase 6: Cycle loading phrases
        startLoadingCycle()

        // Phase 7: Finish and fade out (3.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                fadeOut = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onFinished()
            }
        }
    }

    private func startLoadingCycle() {
        // Animate dots
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if fadeOut < 0.5 {
                timer.invalidate()
                return
            }
            loadingDots = (loadingDots + 1) % 3
        }

        // Rotate phrases
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if fadeOut < 0.5 {
                timer.invalidate()
                return
            }
            phaseIndex = (phaseIndex + 1) % loadingPhrases.count
        }
    }
}
