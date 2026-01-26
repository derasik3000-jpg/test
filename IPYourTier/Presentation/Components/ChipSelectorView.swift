import SwiftUI

public struct ChipSelectorView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(isSelected ? 0.16 : 0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? ThemeColorsConfig.accentBright : Color.clear,
                                    lineWidth: isSelected ? 2 : 0
                                )
                        )
                )
        }
    }
}

public struct ChipGridView: View {
    let options: [String]
    @Binding var selection: String?
    
    public init(options: [String], selection: Binding<String?>) {
        self.options = options
        self._selection = selection
    }
    
    public var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(options, id: \.self) { option in
                ChipSelectorView(
                    title: option,
                    isSelected: selection == option
                ) {
                    selection = option
                }
            }
        }
    }
}

