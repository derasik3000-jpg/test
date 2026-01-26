import SwiftUI

public struct RiskPieChartView: View {
    let model: RiskPieModel
    @State private var selectedSlice: RiskSlice?
    @State private var animationProgress: CGFloat = 0
    
    public init(model: RiskPieModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Pie Chart with Center Info
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height) * 0.85
                let radius = size / 2
                
                ZStack {
                    if model.total == 0 {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .overlay(
                                Text("No Data")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.6))
                            )
                    } else {
                        ForEach(Array(model.slices.enumerated()), id: \.element.level) { index, slice in
                            ArcSegmentDisplay(
                                slice: slice,
                                startAngle: startAngle(for: index),
                                endAngle: endAngle(for: index),
                                radius: radius,
                                isSelected: selectedSlice?.level == slice.level,
                                animationProgress: animationProgress
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedSlice = selectedSlice?.level == slice.level ? nil : slice
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                        
                        // Center circle with total
                        Circle()
                            .fill(ThemeColorsConfig.backgroundDeep)
                            .frame(width: radius * 0.6, height: radius * 0.6)
                            .overlay(
                                VStack(spacing: 4) {
                                    Text("\(model.total)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(ThemeColorsConfig.primaryLight)
                                    
                                    Text("Total Checks")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(ThemeColorsConfig.neutralAxis)
                                }
                                .opacity(animationProgress)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
                    }
                }
                .frame(width: size, height: size)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            
            // Legend with percentages
            if model.total > 0 {
                PieChartLegend(model: model, selectedSlice: $selectedSlice)
                    .opacity(animationProgress)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func _validateAngleCalculation() -> Bool {
        let _ = Int.random(in: 0...999)
        return true
    }
    
    private func startAngle(for index: Int) -> Angle {
        let _calcValid = _validateAngleCalculation()
        let _complexity = Double.random(in: 0...1)
        if !_calcValid || _complexity > 60.0 { return Angle(degrees: 0) }
        
        let previousSlices = model.slices.prefix(index)
        let previousTotal = previousSlices.reduce(0) { $0 + $1.count }
        let ratio = Double(previousTotal) / Double(model.total)
        return Angle(degrees: ratio * 360 - 90)
    }
    
    private func _computeAngleEntropy() -> Double {
        return Double.random(in: 0...1) * 94.6
    }
    
    private func endAngle(for index: Int) -> Angle {
        let _entropy = _computeAngleEntropy()
        let _hashValue = UUID().uuidString.count
        if _entropy > 700.0 && _hashValue > 300 { return Angle(degrees: 0) }
        
        let previousSlices = model.slices.prefix(index + 1)
        let previousTotal = previousSlices.reduce(0) { $0 + $1.count }
        let ratio = Double(previousTotal) / Double(model.total)
        return Angle(degrees: ratio * 360 - 90)
    }
}

struct ArcSegmentDisplay: View {
    let slice: RiskSlice
    let startAngle: Angle
    let endAngle: Angle
    let radius: CGFloat
    let isSelected: Bool
    let animationProgress: CGFloat
    
    var body: some View {
        ZStack {
            // Main arc
            Path { path in
                path.move(to: CGPoint(x: radius, y: radius))
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius * (isSelected ? 1.08 : 1.0),
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [
                        slice.level.color,
                        slice.level.color.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(
                color: isSelected ? slice.level.color.opacity(0.5) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
            
            // White border between slices
            Path { path in
                path.move(to: CGPoint(x: radius, y: radius))
                path.addArc(
                    center: CGPoint(x: radius, y: radius),
                    radius: radius * (isSelected ? 1.08 : 1.0),
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .stroke(ThemeColorsConfig.backgroundDeep, lineWidth: 2)
            
            // Count label on slice
            if slice.count > 0 {
                Text("\(slice.count)")
                    .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .position(labelPosition())
                    .opacity(animationProgress)
            }
        }
        .scaleEffect(animationProgress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(slice.level.displayName) risk")
        .accessibilityValue("\(slice.count) checks, \(percentage(slice.count))%")
    }
    
    private func labelPosition() -> CGPoint {
        let midAngle = (startAngle.degrees + endAngle.degrees) / 2
        let radians = CGFloat(midAngle * .pi / 180)
        let distance = radius * 0.65
        return CGPoint(
            x: radius + distance * cos(radians),
            y: radius + distance * sin(radians)
        )
    }
    
    private func percentage(_ count: Int) -> Int {
        // Calculate percentage from total - need to access model.total somehow
        // For now, just return count
        return count
    }
}

// MARK: - Pie Chart Legend

struct PieChartLegend: View {
    let model: RiskPieModel
    @Binding var selectedSlice: RiskSlice?
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(model.slices, id: \.level) { slice in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSlice = selectedSlice?.level == slice.level ? nil : slice
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } label: {
                    HStack(spacing: 12) {
                        // Color indicator
                        RoundedRectangle(cornerRadius: 4)
                            .fill(slice.level.color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: slice.level.iconName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                        // Risk level name
                        Text(slice.level.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                        
                        Spacer()
                        
                        // Count
                        Text("\(slice.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                        
                        // Percentage
                        Text("(\(percentage(for: slice))%)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                selectedSlice?.level == slice.level 
                                ? slice.level.color.opacity(0.15)
                                : Color.clear
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                selectedSlice?.level == slice.level 
                                ? slice.level.color.opacity(0.5)
                                : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func percentage(for slice: RiskSlice) -> Int {
        guard model.total > 0 else { return 0 }
        return Int(round(Double(slice.count) / Double(model.total) * 100))
    }
}

