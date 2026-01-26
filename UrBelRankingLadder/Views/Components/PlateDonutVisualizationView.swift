import SwiftUI

struct PlateDonutVisualizationView: View {
    let plateData: MealPlateVisualizationDTO
    let size: CGFloat
    let containerWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Donut Chart
            ZStack {
                // Background circle for empty state
                Circle()
                    .stroke(Color.appDivider.opacity(0.3), lineWidth: size * 0.22)
                    .frame(width: size, height: size)
                
                // Segments
                ForEach(Array(plateData.segmentCollection.enumerated()), id: \.element.id) { index, segment in
                    DonutSegmentShape(
                        segment: segment,
                        segmentIndex: index,
                        totalSegments: plateData.segmentCollection.count
                    )
                    .fill(Color(hex: segment.colorHexValue))
                    .overlay(
                        DonutSegmentShape(
                            segment: segment,
                            segmentIndex: index,
                            totalSegments: plateData.segmentCollection.count
                        )
                        .stroke(Color.appBackground, lineWidth: 3)
                    )
                }
                
                // Center content
                VStack(spacing: 6) {
                    // Balance Score
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(plateData.balanceMetric)")
                            .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.appTextPrimary)
                        
                        Text("/100")
                            .font(.system(size: size * 0.08, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                    }
                    
                    // Label
                    Text("Balance")
                        .font(.system(size: size * 0.065, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    // Gold badge
                    if plateData.hasGoldQuality {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: size * 0.055, weight: .bold))
                            Text("Perfect")
                                .font(.system(size: size * 0.055, weight: .semibold))
                        }
                        .foregroundColor(.appAccentYellow)
                        .padding(.top, 2)
                    }
                }
                .padding()
                .background(
                    Circle()
                        .fill(Color.appCardBackground)
                        .frame(width: size * 0.54, height: size * 0.54)
                )
            }
            .frame(width: size, height: size)
            
            // Legend with progress bars
            let legendWidth = containerWidth - 32 // account for horizontal padding
            VStack(spacing: 10) {
                ForEach(plateData.segmentCollection.sorted(by: {
                    sortOrder(for: $0.categoryKey) < sortOrder(for: $1.categoryKey)
                })) { segment in
                    LegendRow(segment: segment, width: legendWidth)
                }
            }
            .frame(width: legendWidth)
        }
        .frame(width: containerWidth)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(generateAccessibilityLabel())
    }
    
    private func sortOrder(for category: SectorCategoryKey) -> Int {
        switch category {
        case .vegetables: return 0
        case .protein: return 1
        case .carbs: return 2
        }
    }
    
    private func generateAccessibilityLabel() -> String {
        let segmentLabels = plateData.segmentCollection.map { $0.voiceOverText }.joined(separator: ", ")
        return "\(segmentLabels). Balance score \(plateData.balanceMetric) out of 100. \(plateData.suggestionText)"
    }
}

// MARK: - Legend Row
struct LegendRow: View {
    let segment: DonutSegmentDTO
    let width: CGFloat
    
    private var emoji: String {
        switch segment.categoryKey {
        case .vegetables: return "🥬"
        case .protein: return "🍖"
        case .carbs: return "🍞"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 8) {
                // Icon with color
                Circle()
                    .fill(Color(hex: segment.colorHexValue).opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(emoji)
                            .font(.system(size: 14))
                    )
                
                // Title
                Text(segment.displayTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                // Progress text
                HStack(spacing: 4) {
                    Text("\(Int(segment.actualPortionCount))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(segment.fillPercentage >= 1.0 ? .appAccentYellow : .appTextPrimary)
                    
                    Text("/ \(Int(segment.targetPortionCount))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            // Progress bar
            let barWidth = width - 20 // account for horizontal padding
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appDivider.opacity(0.3))
                    .frame(width: barWidth, height: 6)
                
                // Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: segment.colorHexValue),
                                Color(hex: segment.colorHexValue).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(0, min(barWidth * segment.fillPercentage, barWidth)),
                        height: 6
                    )
                
                // Overflow indicator
                if segment.excessAmount > 0 && segment.targetPortionCount > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appError.opacity(0.6))
                        .frame(
                            width: min(barWidth * (segment.excessAmount / segment.targetPortionCount), barWidth * 0.3),
                            height: 6
                        )
                        .offset(x: barWidth * min(segment.fillPercentage, 1.0))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(width: width)
        .background(Color.appCardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Donut Segment Shape
struct DonutSegmentShape: Shape {
    let segment: DonutSegmentDTO
    let segmentIndex: Int
    let totalSegments: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let startAngle: Angle
        let segmentAngle: Angle
        
        switch segment.categoryKey {
        case .vegetables:
            startAngle = .degrees(-90)
            segmentAngle = .degrees(180) // 50% of circle (3 parts)
        case .protein:
            startAngle = .degrees(90)
            segmentAngle = .degrees(120) // 33% of circle (2 parts)
        case .carbs:
            startAngle = .degrees(210)
            segmentAngle = .degrees(60) // 17% of circle (1 part)
        }
        
        let fillAngle = segmentAngle.degrees * min(segment.fillPercentage, 1.0)
        let endAngle = startAngle.degrees + fillAngle
        
        let innerRadius = radius * 0.55
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: Angle(degrees: endAngle),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * cos(Angle(degrees: endAngle).radians),
            y: center.y + innerRadius * sin(Angle(degrees: endAngle).radians)
        ))
        
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: Angle(degrees: endAngle),
            endAngle: startAngle,
            clockwise: true
        )
        
        path.closeSubpath()
        
        return path
    }
}

extension Angle {
    var radians: CGFloat {
        CGFloat(self.degrees * .pi / 180)
    }
}
