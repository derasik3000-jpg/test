import SwiftUI

struct CuqavuBarChart: View {
    let degubaDataPoints: [(label: String, energy: Double, mood: Double)]
    let evubewMaxValue: Double
    @State private var axemobAnimationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let barWidth: CGFloat = 40
            let spacing: CGFloat = 20
            let totalWidth = CGFloat(degubaDataPoints.count) * (barWidth * 2 + spacing)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(0..<degubaDataPoints.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary, CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(
                                            width: barWidth,
                                            height: (geometry.size.height - 40) * CGFloat(degubaDataPoints[index].energy / evubewMaxValue) * axemobAnimationProgress
                                        )
                                    
                                    Text("\(Int(degubaDataPoints[index].energy))")
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: geometry.size.height - 40)
                                
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary, CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(
                                            width: barWidth,
                                            height: (geometry.size.height - 40) * CGFloat(degubaDataPoints[index].mood / 5.0) * axemobAnimationProgress
                                        )
                                    
                                    Text("\(Int(degubaDataPoints[index].mood))")
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .frame(height: geometry.size.height - 40)
                            }
                            
                            Text(degubaDataPoints[index].label)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal)
                .frame(minWidth: max(totalWidth, geometry.size.width))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                axemobAnimationProgress = 1.0
            }
        }
    }
}

