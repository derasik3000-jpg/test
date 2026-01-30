import SwiftUI

public struct WharfGoalTagChip: View {
    let quirkTag: VexGoalTag
    let vexIsSelected: Bool
    let plinthAction: () -> Void
    
    public init(quirkTag: VexGoalTag, vexIsSelected: Bool, plinthAction: @escaping () -> Void) {
        self.quirkTag = quirkTag
        self.vexIsSelected = vexIsSelected
        self.plinthAction = plinthAction
    }
    
    public var body: some View {
        Button(action: plinthAction) {
            Text(quirkTag.plinthLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(vexIsSelected ? VexColorPalette.brindleBrandDark : VexColorPalette.wharfTextPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(vexIsSelected ? VexColorPalette.plinthGoalColor(quirkTag) : VexColorPalette.fizzGlassCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vexIsSelected ? VexColorPalette.plinthGoalColor(quirkTag) : VexColorPalette.vexGlassBorder, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

