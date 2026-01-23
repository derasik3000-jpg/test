//
//  SplashView.swift
//  StenorBulano
//
//  Created by Евгений on 21.01.2026.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var circleOffset1: CGFloat = 0
    @State private var circleOffset2: CGFloat = 0
    @State private var circleOffset3: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    ColorTheme.Background.primaryStart,
                    ColorTheme.Background.primaryEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated circles in background with floating effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(pulseScale)
                    .offset(x: -100, y: -200 + circleOffset1)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.03)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 125
                        )
                    )
                    .frame(width: 250, height: 250)
                    .scaleEffect(pulseScale * 0.9)
                    .offset(x: 120, y: 150 + circleOffset2)
                    .blur(radius: 25)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.02)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseScale * 1.1)
                    .offset(x: -80, y: 250 + circleOffset3)
                    .blur(radius: 30)
            }
            
            // Main content
            VStack(spacing: 40) {
                Spacer()
                
                // Animated logo/icon
                ZStack {
                    // Outer rotating ring with gradient
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.4)
                                ]),
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotation))
                    
                    // Middle ring
                    Circle()
                        .stroke(
                            Color.white.opacity(0.25),
                            lineWidth: 2
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-rotation * 0.7))
                    
                    // Inner glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(pulseScale * 0.8)
                    
                    // Inner icon - envelope symbol
                    ZStack {
                        // Envelope body with shadow
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(width: 50, height: 35)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        // Envelope flap
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 25, y: 15))
                            path.addLine(to: CGPoint(x: 50, y: 0))
                        }
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    ColorTheme.Accent.accent500,
                                    ColorTheme.Accent.accent700
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 50, height: 35)
                        .offset(y: -17.5)
                        
                        // Envelope detail line
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 25, y: 15))
                            path.addLine(to: CGPoint(x: 50, y: 0))
                        }
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 50, height: 35)
                        .offset(y: -17.5)
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                }
                
                // Loading indicator with better animation
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.7)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == 0 ? pulseScale : (index == 1 ? pulseScale * 0.9 : pulseScale * 0.8))
                            .opacity(index == 0 ? 1.0 : (index == 1 ? 0.8 : 0.6))
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: pulseScale
                            )
                    }
                }
                .padding(.top, 30)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Scale and fade in animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Continuous rotation
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Floating circles animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            circleOffset1 = 20
        }
        
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            circleOffset2 = -25
        }
        
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            circleOffset3 = 15
        }
    }
}

#Preview {
    SplashView()
}
