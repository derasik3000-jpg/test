import SwiftUI

public struct QyrixDataPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let value: Double
    
    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

public struct QyrixLineChart: View {
    let title: String
    let dataPoints: [QyrixDataPoint]
    let lineColor: Color
    let fillColor: Color
    
    public init(title: String, dataPoints: [QyrixDataPoint], lineColor: Color, fillColor: Color) {
        self.title = title
        self.dataPoints = dataPoints
        self.lineColor = lineColor
        self.fillColor = fillColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(KylorTheme.surface)
            
            if dataPoints.isEmpty {
                Text("No data available")
                    .font(.system(size: 14))
                    .foregroundColor(KylorTheme.surface.opacity(0.6))
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 8) {
                    // Y-axis labels
                    qyrexYAxisLabels
                    
                    // Chart
                    GeometryReader { geometry in
                        VStack(spacing: 4) {
                            qyrexLineChartContent(in: geometry.size)
                            qyrexXAxisLabels
                        }
                    }
                    .frame(height: 180)
                }
            }
        }
        .padding()
        .background(KylorTheme.bgCard)
        .cornerRadius(KylorTheme.cornerRadius)
    }
    
    private var qyrexYAxisLabels: some View {
        let sortedPoints = dataPoints.sorted { $0.date < $1.date }
        let maxValue = sortedPoints.map { $0.value }.max() ?? 1.0
        let minValue = sortedPoints.map { $0.value }.min() ?? 0.0
        
        // If all values are the same, show range around that value
        let (displayMin, displayMax) = {
            if abs(maxValue - minValue) < 0.001 {
                return (max(0, maxValue - 0.1), min(1.0, maxValue + 0.1))
            }
            return (minValue, maxValue)
        }()
        
        return VStack {
            Text(String(format: "%.0f%%", displayMax * 100))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(KylorTheme.surface.opacity(0.7))
            Spacer()
            Text(String(format: "%.0f%%", (displayMax + displayMin) / 2 * 100))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(KylorTheme.surface.opacity(0.7))
            Spacer()
            Text(String(format: "%.0f%%", displayMin * 100))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(KylorTheme.surface.opacity(0.7))
        }
        .frame(width: 35, height: 150)
    }
    
    private var qyrexXAxisLabels: some View {
        let sortedPoints = dataPoints.sorted { $0.date < $1.date }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        
        return HStack {
            if let first = sortedPoints.first {
                Text(formatter.string(from: first.date))
                    .font(.system(size: 10))
                    .foregroundColor(KylorTheme.surface.opacity(0.7))
            }
            
            Spacer()
            
            if sortedPoints.count > 1, let last = sortedPoints.last {
                Text(formatter.string(from: last.date))
                    .font(.system(size: 10))
                    .foregroundColor(KylorTheme.surface.opacity(0.7))
            }
        }
        .frame(height: 20)
    }
    
    private func qyrexLineChartContent(in size: CGSize) -> some View {
        let sortedPoints = dataPoints.sorted { $0.date < $1.date }
        let maxValue = sortedPoints.map { $0.value }.max() ?? 1.0
        let minValue = sortedPoints.map { $0.value }.min() ?? 0.0
        
        // If all values are the same, show range around that value
        let (displayMin, displayMax) = {
            if abs(maxValue - minValue) < 0.001 {
                return (max(0.0, maxValue - 0.1), min(1.0, maxValue + 0.1))
            }
            return (minValue, maxValue)
        }()
        
        let range = displayMax - displayMin
        let xStep = size.width / CGFloat(max(sortedPoints.count - 1, 1))
        
        return ZStack {
            // Grid lines
            ForEach(0..<4) { i in
                let y = size.height * CGFloat(i) / 3.0
                Path { path in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(KylorTheme.timerTrack, style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
            }
            
            // Fill area
            if sortedPoints.count > 1 {
                Path { path in
                    let firstPoint = sortedPoints[0]
                    let firstY = size.height - (CGFloat((firstPoint.value - displayMin) / range) * size.height)
                    path.move(to: CGPoint(x: 0, y: firstY))
                    
                    for (index, point) in sortedPoints.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = size.height - (CGFloat((point.value - displayMin) / range) * size.height)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    // Close the path to the bottom
                    path.addLine(to: CGPoint(x: CGFloat(sortedPoints.count - 1) * xStep, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    gradient: Gradient(colors: [fillColor.opacity(0.3), fillColor.opacity(0.05)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
            
            // Line
            if sortedPoints.count > 1 {
                Path { path in
                    let firstPoint = sortedPoints[0]
                    let firstY = size.height - (CGFloat((firstPoint.value - displayMin) / range) * size.height)
                    path.move(to: CGPoint(x: 0, y: firstY))
                    
                    for (index, point) in sortedPoints.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = size.height - (CGFloat((point.value - displayMin) / range) * size.height)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            
            // Data points
            ForEach(Array(sortedPoints.enumerated()), id: \.element.id) { index, point in
                let x = CGFloat(index) * xStep
                let y = size.height - (CGFloat((point.value - displayMin) / range) * size.height)
                
                Circle()
                    .fill(KylorTheme.surface)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(lineColor, lineWidth: 2)
                    )
                    .position(x: x, y: y)
            }
        }
    }
}

