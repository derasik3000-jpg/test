import SwiftUI

public struct CustomSliderView: View {
    let title: String
    let range: ClosedRange<Int>
    let step: Int
    let majorMarks: [Int]
    @Binding var value: Int
    let unit: String
    
    public init(
        title: String,
        range: ClosedRange<Int>,
        step: Int = 1,
        majorMarks: [Int] = [],
        value: Binding<Int>,
        unit: String = ""
    ) {
        self.title = title
        self.range = range
        self.step = step
        self.majorMarks = majorMarks
        self._value = value
        self.unit = unit
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.8))
                Spacer()
                Text("\(value)\(unit)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { newValue in
                        let snapped = Int(newValue / Double(step)) * step
                        value = min(max(snapped, range.lowerBound), range.upperBound)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step)
            )
            .accentColor(ThemeColorsConfig.accentBright)
            
            if !majorMarks.isEmpty {
                HStack {
                    ForEach(majorMarks, id: \.self) { mark in
                        Text("\(mark)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.6))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
    }
}

