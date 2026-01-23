import SwiftUI

public struct TylorDonutChartView: View {
    let model: TylorDonutModel
    let ringWidth: CGFloat
    let showCenterLegend: Bool
    
    public init(model: TylorDonutModel, ringWidth: CGFloat = 14, showCenterLegend: Bool = true) {
        self.model = model
        self.ringWidth = ringWidth
        self.showCenterLegend = showCenterLegend
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(model.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(KylorTheme.surface)
            
            ZStack {
                ForEach(Array(model.slices.enumerated()), id: \.element.id) { index, slice in
                    QyrexSliceShape(
                        startAngle: qytexStartAngle(for: index),
                        endAngle: qytexEndAngle(for: index)
                    )
                    .stroke(KylorTheme.chartFill, lineWidth: ringWidth)
                }
                
                if showCenterLegend {
                    VStack(spacing: 4) {
                        ForEach(model.slices) { slice in
                            HStack {
                                Circle()
                                    .fill(KylorTheme.chartFill)
                                    .frame(width: 8, height: 8)
                                Text(slice.name)
                                    .font(.caption)
                                    .foregroundColor(KylorTheme.surface)
                            }
                        }
                    }
                }
            }
            .frame(height: 180)
            
            Text(model.caption)
                .font(.caption)
                .foregroundColor(KylorTheme.surface.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private func qytexStartAngle(for index: Int) -> Angle {
        let cumulative = model.slices.prefix(index).reduce(0.0) { $0 + $1.percent }
        return .degrees(cumulative * 360 - 90)
    }
    
    private func qytexEndAngle(for index: Int) -> Angle {
        let cumulative = model.slices.prefix(index + 1).reduce(0.0) { $0 + $1.percent }
        return .degrees(cumulative * 360 - 90)
    }
}

struct QyrexSliceShape: Shape {
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

public struct RykorBarsChartView: View {
    let model: RykorBarsModel
    let barCorner: CGFloat
    let showAttemptsBadges: Bool
    
    public init(model: RykorBarsModel, barCorner: CGFloat = 8, showAttemptsBadges: Bool = true) {
        self.model = model
        self.barCorner = barCorner
        self.showAttemptsBadges = showAttemptsBadges
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(KylorTheme.surface)
            
            ForEach(model.bars) { bar in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(bar.block)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(KylorTheme.surface)
                        Spacer()
                        Text(VylorFormatters.gyrexPercent(bar.percent))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(KylorTheme.surface)
                        if showAttemptsBadges {
                            Text("(\(bar.attempts))")
                                .font(.caption)
                                .foregroundColor(KylorTheme.surface.opacity(0.7))
                        }
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: barCorner)
                                .fill(KylorTheme.chartGrid)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: barCorner)
                                .fill(KylorTheme.chartFill)
                                .frame(width: geo.size.width * CGFloat(bar.percent), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
    }
}

public struct ZylorTimelineChartView: View {
    let model: ZylorTimelineModel
    let showConversionBadges: Bool
    
    public init(model: ZylorTimelineModel, showConversionBadges: Bool = true) {
        self.model = model
        self.showConversionBadges = showConversionBadges
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(KylorTheme.surface)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    ForEach(model.bands) { band in
                        let xStart = CGFloat(band.startMin / model.totalMinutes) * geo.size.width
                        let width = CGFloat(band.durationMin / model.totalMinutes) * geo.size.width
                        
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(KylorTheme.chartFill)
                                .frame(width: max(width - 4, 0), height: 40)
                                .overlay(
                                    Text(band.type)
                                        .font(.caption)
                                        .foregroundColor(KylorTheme.surface)
                                )
                            
                            if showConversionBadges, let conv = band.conversion {
                                Text(VylorFormatters.gyrexPercent(conv))
                                    .font(.caption2)
                                    .padding(4)
                                    .background(KylorTheme.accentBase)
                                    .foregroundColor(KylorTheme.accentOn)
                                    .cornerRadius(4)
                            }
                        }
                        .offset(x: xStart)
                    }
                }
            }
            .frame(height: 50)
        }
    }
}

public struct VyroxSparkChartView: View {
    let model: VyroxSparkModel
    
    public init(model: VyroxSparkModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.title)
                .font(.caption)
                .foregroundColor(KylorTheme.surface.opacity(0.8))
            
            GeometryReader { geo in
                let maxAttempts = model.points.map(\.attempts).max() ?? 1
                
                Path { path in
                    for (index, point) in model.points.enumerated() {
                        let x = CGFloat(index) / CGFloat(max(model.points.count - 1, 1)) * geo.size.width
                        let y = geo.size.height - (CGFloat(point.attempts) / CGFloat(maxAttempts) * geo.size.height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(KylorTheme.timerStroke, lineWidth: 2)
            }
            .frame(height: 60)
        }
    }
}

