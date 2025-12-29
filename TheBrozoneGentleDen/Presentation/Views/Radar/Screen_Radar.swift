import SwiftUI

struct RadarView: View {
    @StateObject private var viewModel: RadarOverviewViewModel
    
    init() {
        let container = DependencyContainer.shared
        _viewModel = StateObject(wrappedValue: RadarOverviewViewModel(
            getRadar: container.getRadarOverviewUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuroraThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AuroraThemeColors.pureWhite)
                } else if viewModel.emptyStateVisible {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 64))
                            .foregroundColor(AuroraThemeColors.pureWhite)
                        
                        Text("Radar awakens when spheres have improvements")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AuroraThemeColors.lightGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Text("Add your first progress photo")
                            .font(.system(size: 16))
                            .foregroundColor(AuroraThemeColors.mediumGray)
                    }
                } else if let data = viewModel.donutData {
                    ScrollView {
                        VStack(spacing: 24) {
                            CircularGraphDisplay(data: data)
                                .frame(height: 300)
                                .padding()
                            
                            VStack(spacing: 12) {
                                ForEach(data.segments) { segment in
                                    SegmentRowView(segment: segment)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Radar")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadRadarOverviewDonutData()
            }
            .refreshable {
                await viewModel.loadRadarOverviewDonutData()
            }
        }
    }
}

struct RangeSelectorView: View {
    @Binding var selectedRange: ChronoTimeRange.TimeframeCategory
    let onChange: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach([ChronoTimeRange.TimeframeCategory.week, .month, .last90Days], id: \.self) { range in
                Button {
                    selectedRange = range
                    onChange()
                } label: {
                    Text(rangeTitle(for: range))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedRange == range ? AuroraThemeColors.deepCharcoal : AuroraThemeColors.lightGray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedRange == range ? AuroraThemeColors.pureWhite : AuroraThemeColors.deepCharcoal.opacity(0.4))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func rangeTitle(for range: ChronoTimeRange.TimeframeCategory) -> String {
        switch range {
        case .week: return "Week"
        case .month: return "Month"
        case .last90Days: return "90 Days"
        case .custom: return "Custom"
        }
    }
}

extension ChronoTimeRange.TimeframeCategory: Hashable {
    static func == (lhs: ChronoTimeRange.TimeframeCategory, rhs: ChronoTimeRange.TimeframeCategory) -> Bool {
        switch (lhs, rhs) {
        case (.week, .week), (.month, .month), (.last90Days, .last90Days):
            return true
        case (.custom(let l1, let l2), .custom(let r1, let r2)):
            return l1 == r1 && l2 == r2
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .week:
            hasher.combine("week")
        case .month:
            hasher.combine("month")
        case .last90Days:
            hasher.combine("90days")
        case .custom(let start, let end):
            hasher.combine("custom")
            hasher.combine(start)
            hasher.combine(end)
        }
    }
}

struct CircularGraphDisplay: View {
    let data: CosmicDonutData
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AuroraThemeColors.deepCharcoal.opacity(0.3), lineWidth: 40)
            
            ForEach(Array(data.segments.enumerated()), id: \.element.id) { index, segment in
                CircularDataPointShape(
                    startAngle: startAngle(for: index),
                    endAngle: endAngle(for: index)
                )
                .stroke(segmentColor(for: index), lineWidth: 40)
            }
            
            VStack(spacing: 8) {
                Text("\(data.totalScore)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("Total Score")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AuroraThemeColors.lightGray)
            }
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousSegments = data.segments.prefix(index)
        let total = data.segments.reduce(0.0) { $0 + $1.value }
        let previousSum = previousSegments.reduce(0.0) { $0 + $1.value }
        return .degrees(previousSum / total * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let segmentsUpTo = data.segments.prefix(index + 1)
        let total = data.segments.reduce(0.0) { $0 + $1.value }
        let sum = segmentsUpTo.reduce(0.0) { $0 + $1.value }
        return .degrees(sum / total * 360 - 90)
    }
    
    private func segmentColor(for index: Int) -> Color {
        let colors: [Color] = [
            AuroraThemeColors.lightGray,
            AuroraThemeColors.pureWhite.opacity(0.7),
            AuroraThemeColors.lightGray.opacity(0.5),
            AuroraThemeColors.pureWhite.opacity(0.4)
        ]
        return colors[index % colors.count]
    }
}

struct CircularDataPointShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path
    }
}

struct SegmentRowView: View {
    let segment: CosmicDonutData.CircularDataPoint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(segment.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AuroraThemeColors.pureWhite)
                
                Text("\(Int(segment.value)) points")
                    .font(.system(size: 14))
                    .foregroundColor(AuroraThemeColors.lightGray)
            }
            
            Spacer()
            
            if let trend = segment.trendHint {
                TrendIndicator(trend: trend)
            }
        }
        .padding()
        .prismaticCard()
    }
}

struct TrendIndicator: View {
    let trend: CosmicDonutData.TrendHint
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .semibold))
            Text(trendText)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(trendColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(trendColor.opacity(0.2))
        .cornerRadius(6)
    }
    
    private var iconName: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    private var trendText: String {
        switch trend {
        case .up(let delta): return "+\(Int(delta))"
        case .down(let delta): return "-\(Int(delta))"
        case .stable: return "0"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return AuroraThemeColors.mediumGray
        }
    }
}

