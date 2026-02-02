import SwiftUI

struct EvubewLineChart: View {
    let cuqavuDataPoints: [Double]
    let axemobLabels: [String]
    let ehonohMaxValue: Double
    @State private var degubaAnimationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = width / CGFloat(max(cuqavuDataPoints.count - 1, 1))
            let stepY = height / CGFloat(ehonohMaxValue)
            
            ZStack(alignment: .bottomLeading) {
                Path { path in
                    for i in 0..<cuqavuDataPoints.count {
                        let x = CGFloat(i) * stepX
                        let y = height - (CGFloat(cuqavuDataPoints[i]) * stepY)
                        
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .trim(from: 0, to: degubaAnimationProgress)
                .stroke(
                    LinearGradient(
                        colors: [CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary, CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                
                Path { path in
                    guard !cuqavuDataPoints.isEmpty else { return }
                    
                    path.move(to: CGPoint(x: 0, y: height - (CGFloat(cuqavuDataPoints[0]) * stepY)))
                    
                    for i in 0..<cuqavuDataPoints.count {
                        let x = CGFloat(i) * stepX
                        let y = height - (CGFloat(cuqavuDataPoints[i]) * stepY)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3), CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(Double(degubaAnimationProgress))
                
                ForEach(0..<cuqavuDataPoints.count, id: \.self) { index in
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(cuqavuDataPoints[index]) * stepY)
                    
                    Circle()
                        .fill(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary, lineWidth: 2)
                        )
                        .position(x: x, y: y)
                        .scaleEffect(degubaAnimationProgress)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                degubaAnimationProgress = 1.0
            }
        }
    }
}

