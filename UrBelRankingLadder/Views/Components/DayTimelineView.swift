import SwiftUI

struct DayTimelineView: View {
    let timelineData: DayTimelineVisualizationDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Meals")
                .font(.headline)
                .foregroundColor(.appDarkText)
            
            HStack(spacing: 0) {
                ForEach(timelineData.slotSegments) { segment in
                    VStack(spacing: 4) {
                        Text(segment.displayLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.appDarkText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appAquaCyan.opacity(Double(segment.metricValue) / 100.0),
                                        Color.appDeepSkyBlue.opacity(Double(segment.metricValue) / 100.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(segment.voiceOverText)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

