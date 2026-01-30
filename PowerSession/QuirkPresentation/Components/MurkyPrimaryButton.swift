import SwiftUI

public struct MurkyPrimaryButton: View {
    let quellTitle: String
    let vexAction: () -> Void
    
    public init(quellTitle: String, vexAction: @escaping () -> Void) {
        self.quellTitle = quellTitle
        self.vexAction = vexAction
    }
    
    public var body: some View {
        Button(action: vexAction) {
            Text(quellTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(VexColorPalette.brindleBrandDark)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(VexColorPalette.plinthPrimaryButton)
                )
        }
        .buttonStyle(.plain)
    }
}

public struct TarnSecondaryButton: View {
    let plinthTitle: String
    let fizzAction: () -> Void
    
    public init(plinthTitle: String, fizzAction: @escaping () -> Void) {
        self.plinthTitle = plinthTitle
        self.fizzAction = fizzAction
    }
    
    public var body: some View {
        Button(action: fizzAction) {
            Text(plinthTitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(VexColorPalette.wharfTextPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(VexColorPalette.fizzGlassCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

