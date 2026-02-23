// ──────────────────────────────────────────────
// KitchenSplashScreenView.swift
// Culinary Routine Choose & Chill
//
// Loading screen shown during initialization.
// Animated gradient, progress ring, "Preparing..." text.
// Culinary-themed splash.
// ──────────────────────────────────────────────

import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - 🍳 KitchenSplashScreenView
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct KitchenSplashScreenView: View {

    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.07, blue: 0.09),
                    Color(red: 0.11, green: 0.11, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: KitchenSpacing.tray) {
                Spacer()

                // Central ring + progress
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.77, green: 0.64, blue: 0.33).opacity(0.2), lineWidth: 3)
                        .frame(width: 112, height: 112)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(red: 0.77, green: 0.64, blue: 0.33), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))

                    Text("12")
                        .font(.system(size: 48, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(red: 0.77, green: 0.64, blue: 0.33))
                }

                Text("Menu of 12 Dishes")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Text("Preparing…")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(red: 0.69, green: 0.69, blue: 0.70))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.77, green: 0.64, blue: 0.33).opacity(0.25))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.77, green: 0.64, blue: 0.33))
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(width: 160, height: 4)

                Spacer()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5)) {
                    progress = 0.95
                }
            }
        }
        .ignoresSafeArea(.all, edges: .all)
    }
}
