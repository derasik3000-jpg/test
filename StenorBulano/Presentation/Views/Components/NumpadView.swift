import SwiftUI

struct NumpadView: View {
    let onDigit: (String) -> Void
    let onDecimal: () -> Void
    let onBackspace: () -> Void
    
    private let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        NumpadButton(text: button) {
                            handleTap(button)
                        }
                    }
                }
            }
        }
        .padding()
        .background(ColorTheme.Background.sunken)
    }
    
    private func handleTap(_ button: String) {
        switch button {
        case ".":
            onDecimal()
        case "⌫":
            onBackspace()
        default:
            onDigit(button)
        }
    }
}

struct NumpadButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(ColorTheme.Text.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ColorTheme.Button.fill)
                .cornerRadius(12)
        }
    }
}

