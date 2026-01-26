import SwiftUI

public struct RiskDonutChartView: View {
    let model: RiskDonutModel
    @State private var animationProgress: CGFloat = 0
    
    public init(model: RiskDonutModel) {
        self.model = model
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth = size * 0.18
            let radius = (size - lineWidth) / 2
            
            ZStack {
                Circle()
                    .stroke(
                        Color.white.opacity(0.15),
                        lineWidth: lineWidth
                    )
                
                Circle()
                    .trim(from: 0, to: CGFloat(model.ratio) * animationProgress)
                    .stroke(
                        ThemeColorsConfig.riskColor(for: model.level),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(model.level.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    Text("\(model.score)/\(model.max)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
            
            if model.level == .red {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Risk level: \(model.level.displayName)")
        .accessibilityValue("Score \(model.score) out of \(model.max)")
    }
}

