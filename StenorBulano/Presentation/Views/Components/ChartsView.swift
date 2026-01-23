import SwiftUI
import Charts

struct PieChartView: View {
    let data: [(name: String, value: Double, color: Color)]
    
    var body: some View {
        GeometryReader { geometry in
            if data.isEmpty || totalValue() <= 0 {
                Text("No data")
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ZStack {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        PieSlice(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            color: item.color
                        )
                    }
                    
                    Circle()
                        .fill(ColorTheme.Background.raised)
                        .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                    
                    VStack(spacing: 4) {
                        Text("Total")
                            .font(Typography.caption())
                            .foregroundColor(.white)
                        Text(formatTotal())
                            .font(Typography.body())
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func totalValue() -> Double {
        return data.reduce(0.0) { $0 + $1.value }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let sum = data.prefix(index).reduce(0.0) { $0 + $1.value }
        let total = totalValue()
        guard total > 0 else { return Angle(degrees: 0) }
        return Angle(degrees: -90 + (sum / total * 360))
    }
    
    private func endAngle(for index: Int) -> Angle {
        let sum = data.prefix(index + 1).reduce(0.0) { $0 + $1.value }
        let total = totalValue()
        guard total > 0 else { return Angle(degrees: 0) }
        return Angle(degrees: -90 + (sum / total * 360))
    }
    
    private func formatTotal() -> String {
        let total = totalValue()
        return String(format: "%.0f%%", total)
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                           startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

struct BarChartView: View {
    let data: [(name: String, value: Double, color: Color)]
    
    var body: some View {
        GeometryReader { geometry in
            if data.isEmpty {
                Text("No data")
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 8) {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(item.color)
                                .frame(width: barWidth(in: geometry.size.width),
                                       height: barHeight(for: item.value, in: geometry.size.height - 40))
                            
                            Text(item.name)
                                .font(Typography.caption())
                                .foregroundColor(ColorTheme.Text.secondary)
                                .lineLimit(1)
                                .frame(width: barWidth(in: geometry.size.width))
                        }
                    }
                }
            }
        }
    }
    
    private func barWidth(in totalWidth: CGFloat) -> CGFloat {
        guard data.count > 0 else { return 0 }
        let spacing = CGFloat(data.count - 1) * 12
        let availableWidth = max(0, totalWidth - spacing)
        return availableWidth / CGFloat(data.count)
    }
    
    private func barHeight(for value: Double, in maxHeight: CGFloat) -> CGFloat {
        guard maxHeight > 0 else { return 0 }
        let maxValue = data.map { $0.value }.max() ?? 1.0
        guard maxValue > 0 else { return 0 }
        let height = CGFloat(value / maxValue) * maxHeight
        return max(0, min(height, maxHeight))
    }
}

