import SwiftUI

public struct RiskBarChartView: View {
    let model: RiskBarModel
    @State private var animationProgress: CGFloat = 0
    @State private var selectedPoint: RiskBarPoint?
    
    public init(model: RiskBarModel) {
        self.model = model
    }
    
    private var maxRiskValue: Double {
        // Map risk levels to numeric values for height calculation
        let values = model.points.map { point -> Double in
            switch point.level {
            case .low: return 1.0
            case .medium: return 2.0
            case .high: return 3.0
            case .red: return 4.0
            }
        }
        return values.max() ?? 1.0
    }
    
    private func barHeight(for point: RiskBarPoint, maxHeight: CGFloat) -> CGFloat {
        let value: Double
        switch point.level {
        case .low: value = 1.0
        case .medium: value = 2.0
        case .high: value = 3.0
        case .red: value = 4.0
        }
        return maxHeight * CGFloat(value / maxRiskValue) * 0.85
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Chart
            GeometryReader { geometry in
                let barWidth = max(30, (geometry.size.width - CGFloat(model.points.count + 1) * 12) / CGFloat(max(1, model.points.count)))
                let maxHeight = geometry.size.height - 50
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(Array(model.points.enumerated()), id: \.element.id) { index, point in
                            VStack(spacing: 6) {
                                // Value label on top of bar
                                Text(point.level.shortName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(point.level.color)
                                    .opacity(animationProgress)
                                
                                // Bar with gradient
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    point.level.color,
                                                    point.level.color.opacity(0.7)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: barWidth, height: barHeight(for: point, maxHeight: maxHeight) * animationProgress)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    selectedPoint?.id == point.id ? Color.white.opacity(0.5) : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .shadow(
                                            color: point.level.color.opacity(0.3),
                                            radius: selectedPoint?.id == point.id ? 8 : 4,
                                            x: 0,
                                            y: 2
                                        )
                                    
                                    // Risk icon inside bar
                                    if barHeight(for: point, maxHeight: maxHeight) > 30 {
                                        Image(systemName: point.level.iconName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding(.bottom, 8)
                                            .opacity(animationProgress)
                                    }
                                }
                                .scaleEffect(selectedPoint?.id == point.id ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedPoint?.id)
                                
                                // Date label
                                Text(formattedDate(point.date))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(
                                        selectedPoint?.id == point.id 
                                        ? ThemeColorsConfig.accentBright 
                                        : ThemeColorsConfig.primaryLight.opacity(0.6)
                                    )
                                    .frame(width: barWidth)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPoint = selectedPoint?.id == point.id ? nil : point
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(formattedDate(point.date)): \(point.level.displayName) risk")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                }
            }
            
            // Legend
            RiskLegendView()
                .opacity(animationProgress)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Risk Legend

struct RiskLegendView: View {
    var body: some View {
        HStack(spacing: 16) {
            LegendItem(level: .low)
            LegendItem(level: .medium)
            LegendItem(level: .high)
            LegendItem(level: .red)
        }
        .padding(.horizontal, 12)
    }
}

struct LegendItem: View {
    let level: RiskLevel
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(level.color)
                .frame(width: 8, height: 8)
            
            Text(level.shortName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
        }
    }
}

