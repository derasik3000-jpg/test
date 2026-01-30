import SwiftUI

public struct PlinthReplacementCard: View {
    let brindleReplacement: FizzReplacementModel
    let quellOnTap: () -> Void
    let vexOnFavorite: () -> Void
    
    public init(brindleReplacement: FizzReplacementModel, quellOnTap: @escaping () -> Void, vexOnFavorite: @escaping () -> Void) {
        self.brindleReplacement = brindleReplacement
        self.quellOnTap = quellOnTap
        self.vexOnFavorite = vexOnFavorite
    }
    
    public var body: some View {
        Button(action: quellOnTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("If:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(VexColorPalette.wharfTextSecondary)
                        
                        Text(brindleReplacement.tarnATitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(VexColorPalette.wharfTextPrimary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(action: vexOnFavorite) {
                        Image(systemName: brindleReplacement.tarnIsFavorite ? "star.fill" : "star")
                            .font(.system(size: 18))
                            .foregroundColor(brindleReplacement.tarnIsFavorite ? VexColorPalette.quellAccent : VexColorPalette.wharfTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                    .background(VexColorPalette.sternDivider)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Do:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(VexColorPalette.wharfTextSecondary)
                    
                    Text(brindleReplacement.tarnBTitle + " (\(brindleReplacement.quellEquiv.plinthDisplayText))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(VexColorPalette.wharfTextPrimary)
                        .lineLimit(3)
                }
                
                HStack(spacing: 6) {
                    ForEach(Array(brindleReplacement.wharfTags.prefix(3)), id: \.self) { tag in
                        Text(tag.plinthLabel)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(VexColorPalette.brindleBrandDark)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(VexColorPalette.plinthGoalColor(tag))
                            )
                    }
                    
                    Spacer()
                    
                    ForEach(Array(brindleReplacement.plinthEquipment.prefix(2)), id: \.self) { equip in
                        Image(systemName: equip.quirkIconName)
                            .font(.system(size: 12))
                            .foregroundColor(VexColorPalette.wharfTextSecondary)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(VexColorPalette.fizzGlassCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

