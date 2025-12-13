import SwiftUI

struct GamingOnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage: Int = 0
    @State private var iconScale: CGFloat = 1.0
    @State private var iconRotation: Double = 0
    
    var body: some View {
        ZStack {
            GamingGradientBackgroundView()
            
            TabView(selection: $currentPage) {
                GamingOnboardingPageView(
                    icon: "gamecontroller",
                    title: "Welcome to EGL Gaming Support",
                    description: "Level up your gaming experience",
                    pageIndex: 0,
                    iconScale: $iconScale,
                    iconRotation: $iconRotation
                )
                .tag(0)
                
                GamingOnboardingPageView(
                    icon: "lightbulb",
                    title: "Ideate and Level",
                    description: "Capture ideas, build epic programs",
                    pageIndex: 1,
                    iconScale: $iconScale,
                    iconRotation: $iconRotation
                )
                .tag(1)
                
                GamingOnboardingPageView(
                    icon: "calendar",
                    title: "Plan Your Game",
                    description: "Schedule sessions, never miss a match",
                    pageIndex: 2,
                    iconScale: $iconScale,
                    iconRotation: $iconRotation
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onChange(of: currentPage) { _ in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    iconScale = 0.8
                    iconRotation += 360
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        iconScale = 1.0
                    }
                }
            }
            
            VStack {
                Spacer()
                
                if currentPage == 2 {
                    Button(action: {
                        withAnimation {
                            isComplete = true
                        }
                    }) {
                        HStack {
                            Text("Start Your Journey")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(GamingColorPalette.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple,
                                    GamingColorPalette.primaryMagenta
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: GamingColorPalette.primaryPurple.opacity(0.5), radius: 15, x: 0, y: 8)
                        .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.3), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                    }
                } else {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            currentPage += 1
                        }
                    }) {
                        HStack {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(GamingColorPalette.textOnAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    GamingColorPalette.primaryPurple,
                                    GamingColorPalette.primaryMagenta
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: GamingColorPalette.primaryPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onAppear {
            iconScale = 1.0
            iconRotation = 0
        }
    }
}

struct GamingOnboardingPageView: View {
    let icon: String
    let title: String
    let description: String
    let pageIndex: Int
    @Binding var iconScale: CGFloat
    @Binding var iconRotation: Double
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                GamingColorPalette.primaryPurple.opacity(0.2),
                                GamingColorPalette.primaryMagenta.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                // Icon with gradient
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                GamingColorPalette.primaryPurple,
                                GamingColorPalette.primaryMagenta
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
                    .shadow(color: GamingColorPalette.primaryPurple.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(GamingColorPalette.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(GamingColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
    }
}
