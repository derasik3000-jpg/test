import SwiftUI

struct SplashIlluminationView: View {
    @Binding var showSplash: Bool
    @State private var moonScale: CGFloat = 0.5
    @State private var moonOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            LinearGradient.celestialBackdrop
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.lavenderMist.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .blur(radius: 30)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.nebulaBlossom.opacity(0.8), Color.lavenderMist],
                                center: .center,
                                startRadius: 40,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(moonScale)
                        .opacity(moonOpacity)
                }
                
                Text("Luna")
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundColor(.shadowText)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                moonScale = 1.1
                moonOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

