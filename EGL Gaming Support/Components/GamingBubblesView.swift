import SwiftUI

struct GamingBubblesView: View {
    let iconCount: Int
    let iconColor: Color
    let iconType: String
    let useFixedPositions: Bool
    
    init(iconCount: Int, iconColor: Color, iconType: String, useFixedPositions: Bool = false) {
        self.iconCount = iconCount
        self.iconColor = iconColor
        self.iconType = iconType
        self.useFixedPositions = useFixedPositions
    }
    
    @State private var bubbleIcons: [String] = []
    
    // Linear minimalistic icons
    let gamingIcons = [
        "gamecontroller",
        "dpad",
        "circle.grid.cross",
        "square",
        "sparkles",
        "star",
        "trophy",
        "play.circle",
        "pause.circle",
        "stop.circle",
        "arrow.triangle.2.circlepath.circle",
        "heart"
    ]
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        let displayCount = min(max(iconCount, 8), 20)
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<displayCount, id: \.self) { index in
                GamingBubbleView(
                    iconName: bubbleIcons.indices.contains(index) ? bubbleIcons[index] : gamingIcons[index % gamingIcons.count],
                    color: iconColor,
                    size: 50 + CGFloat(index % 3) * 6,
                    rotation: Double(index % 2 == 0 ? -12 : 12)
                )
            }
        }
        .frame(height: 200)
        .padding(.vertical, 8)
        .onAppear {
            setupIcons()
        }
        .onChange(of: iconCount) { _ in
            setupIcons()
        }
    }
    
    private func setupIcons() {
        let count = min(max(iconCount, 8), 20)
        bubbleIcons = (0..<count).map { index in
            gamingIcons[index % gamingIcons.count]
        }
    }
}

struct GamingBubbleView: View {
    let iconName: String
    let color: Color
    let size: CGFloat
    let rotation: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.9),
                            color.opacity(0.6),
                            color.opacity(0.3)
                        ]),
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: color.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Linear minimalistic icon - light on dark
            Image(systemName: iconName)
                .font(.system(size: size * 0.35, weight: .light))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .rotationEffect(.degrees(rotation))
        .frame(maxWidth: .infinity)
    }
}
