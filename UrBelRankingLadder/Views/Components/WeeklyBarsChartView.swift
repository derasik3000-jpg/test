import SwiftUI

struct WeeklyBarsChartView: View {
    let barsData: WeeklyBarsVisualizationDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(barsData.captionText)
                .font(.caption)
                .foregroundColor(.appDarkText.opacity(0.7))
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(barsData.dayBars) { bar in
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 80)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAquaCyan, Color.appDeepSkyBlue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 40, height: CGFloat(bar.averageMetric) * 0.8)
                            
                            if bar.hasGoldQuality {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                    .offset(y: -8)
                            }
                        }
                        
                        Text(extractDayMonth(from: bar.dayIdentifier))
                            .font(.system(size: 10))
                            .foregroundColor(.appDarkText.opacity(0.6))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(bar.voiceOverText)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.0))
        )
    }
    
    private func extractDayMonth(from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        if components.count >= 3 {
            return "\(components[2])/\(components[1])"
        }
        return dateString
    }
}

