import SwiftUI

struct PowerSplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [
                    VexColorPalette.murkyGradientEnd,
                    VexColorPalette.murkyGradientStart
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App title/logo
                VStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .foregroundColor(VexColorPalette.quellAccent)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Text("PowerSession")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(VexColorPalette.quellAccent)
                }
                
                Spacer()
                
                // Circular loader
                VStack(spacing: 20) {
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(
                                VexColorPalette.quellAccent.opacity(0.2),
                                lineWidth: 4
                            )
                            .frame(width: 60, height: 60)
                        
                        // Animated circle
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                VexColorPalette.quellAccent,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 1.0)
                                    .repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                    }
                    
                    Text("Loading")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(VexColorPalette.quellAccent)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

