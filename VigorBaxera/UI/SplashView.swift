//
//  SplashView.swift
//  VigorBaxera
//
//  Created by Евгений on 21.01.2026.
//

import SwiftUI

// MARK: - Splash View
struct SplashView: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient - Orange & Pink theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.05, blue: 0.1),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles background
            ParticlesBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App logo/icon with animation
                ZStack {
                    // Outer glow ring - Orange & Pink
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.3),
                                    Color.pink.opacity(0.3),
                                    Color(red: 1.0, green: 0.4, blue: 0.6).opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .opacity(pulseAnimation ? 0.5 : 1.0)
                    
                    // Middle ring - Orange & Pink
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.6),
                                    Color.pink.opacity(0.6)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Inner circle with icon - Orange & Pink
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.orange.opacity(0.8),
                                        Color.pink.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.orange.opacity(0.5), radius: 20, x: 0, y: 0)
                        
                        // App icon/symbol
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, Color.orange.opacity(0.9)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
                
                // Loading indicator
                LoadingBar(isAnimating: $isAnimating)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Start Animations
    private func startAnimations() {
        // Main scale and fade animation
        withAnimation(.easeOut(duration: 0.8)) {
            isAnimating = true
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
        
        // Rotation animation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

// MARK: - Loading Bar
struct LoadingBar: View {
    @Binding var isAnimating: Bool
    @State private var progress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                
                // Progress bar - Orange & Pink
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange,
                                Color(red: 1.0, green: 0.5, blue: 0.3),
                                Color.pink
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 6)
                    .shadow(color: Color.orange.opacity(0.5), radius: 5, x: 0, y: 0)
            }
        }
        .frame(height: 6)
        .frame(maxWidth: 200)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                progress = 1.0
            }
        }
    }
}

// MARK: - Particles Background
struct ParticlesBackground: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .blur(radius: particle.blur)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                startParticleAnimation()
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...6),
                color: [Color.orange, Color.pink, Color(red: 1.0, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.4, blue: 0.6)].randomElement() ?? .orange,
                opacity: Double.random(in: 0.1...0.3),
                blur: CGFloat.random(in: 2...5)
            )
        }
    }
    
    private func startParticleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                for index in particles.indices {
                    particles[index].position.y -= CGFloat.random(in: 0.5...2.0)
                    particles[index].position.x += CGFloat.random(in: -1...1)
                    
                    // Reset particle if it goes off screen
                    if particles[index].position.y < -10 {
                        particles[index].position.y = UIScreen.main.bounds.height + 10
                        particles[index].position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                    }
                }
            }
        }
    }
}

// MARK: - Particle Model
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let color: Color
    let opacity: Double
    let blur: CGFloat
}

// MARK: - Preview
#Preview {
    SplashView()
}
