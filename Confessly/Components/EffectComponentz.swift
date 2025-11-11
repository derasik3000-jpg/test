import SwiftUI

struct ProgressDotziIndicator: View {
    let totalDotzi: Int
    let currentDotzi: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalDotzi, id: \.self) { indexz in
                Circle()
                    .fill(indexz <= currentDotzi ? Color.primaryPinkz : Color.neutralGreyz)
                    .frame(width: 10, height: 10)
                    .scaleEffect(indexz == currentDotzi ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentDotzi)
            }
        }
    }
}

struct ConfettiCirclez: View {
    @State private var animatez = false
    let colorz: Color
    let offsetXz: CGFloat
    let offsetYz: CGFloat
    
    var body: some View {
        Circle()
            .fill(colorz)
            .frame(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6))
            .offset(x: animatez ? offsetXz : 0, y: animatez ? offsetYz : 0)
            .opacity(animatez ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animatez = true
                }
            }
    }
}

struct ConfettiBurstViewz: View {
    var body: some View {
        ZStack {
            ForEach(0..<15) { _ in
                ConfettiCirclez(
                    colorz: [.primaryPinkz, .telemagentaz, .successGreenz].randomElement() ?? .primaryPinkz,
                    offsetXz: CGFloat.random(in: -100...100),
                    offsetYz: CGFloat.random(in: -150...50)
                )
            }
        }
    }
}

