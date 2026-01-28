import SwiftUI

struct EhonohTimelineChart: View {
    let axemobSummaries: [CuqavuDailySummaryModel]
    @State private var degubaAnimationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxValue = axemobSummaries.map { Double($0.degubaTotalMinutes) }.max() ?? 1
            let barWidth: CGFloat = 30
            let spacing: CGFloat = 12
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(axemobSummaries.reversed()) { summary in
                        VStack(spacing: 4) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.15))
                                    .frame(width: barWidth, height: height - 40)
                                
                                VStack(spacing: 0) {
                                    if summary.totalWorkMin > 0 {
                                        Rectangle()
                                            .fill(EhonohSessionType.work.cuqavuColor)
                                            .frame(
                                                width: barWidth,
                                                height: evubewCalculateHeight(
                                                    value: Double(summary.totalWorkMin),
                                                    maxValue: maxValue,
                                                    totalHeight: height - 40
                                                )
                                            )
                                    }
                                    if summary.totalStudyMin > 0 {
                                        Rectangle()
                                            .fill(EhonohSessionType.study.cuqavuColor)
                                            .frame(
                                                width: barWidth,
                                                height: evubewCalculateHeight(
                                                    value: Double(summary.totalStudyMin),
                                                    maxValue: maxValue,
                                                    totalHeight: height - 40
                                                )
                                            )
                                    }
                                    if summary.totalSportMin > 0 {
                                        Rectangle()
                                            .fill(EhonohSessionType.sport.cuqavuColor)
                                            .frame(
                                                width: barWidth,
                                                height: evubewCalculateHeight(
                                                    value: Double(summary.totalSportMin),
                                                    maxValue: maxValue,
                                                    totalHeight: height - 40
                                                )
                                            )
                                    }
                                    if summary.totalRestMin > 0 {
                                        Rectangle()
                                            .fill(EhonohSessionType.rest.cuqavuColor)
                                            .frame(
                                                width: barWidth,
                                                height: evubewCalculateHeight(
                                                    value: Double(summary.totalRestMin),
                                                    maxValue: maxValue,
                                                    totalHeight: height - 40
                                                )
                                            )
                                    }
                                }
                                .cornerRadius(8)
                                .scaleEffect(y: degubaAnimationProgress, anchor: .bottom)
                            }
                            
                            Text(cuqavuFormatDate(summary.date))
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                degubaAnimationProgress = 1.0
            }
        }
    }
    
    private func evubewCalculateHeight(value: Double, maxValue: Double, totalHeight: CGFloat) -> CGFloat {
        return CGFloat(value / maxValue) * totalHeight
    }
    
    private func cuqavuFormatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

