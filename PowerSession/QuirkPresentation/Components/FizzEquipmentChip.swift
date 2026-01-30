import SwiftUI

public struct FizzEquipmentChip: View {
    let tarnEquipment: PlinthEquipment
    let murkyIsSelected: Bool
    let sternAction: () -> Void
    
    public init(tarnEquipment: PlinthEquipment, murkyIsSelected: Bool, sternAction: @escaping () -> Void) {
        self.tarnEquipment = tarnEquipment
        self.murkyIsSelected = murkyIsSelected
        self.sternAction = sternAction
    }
    
    public var body: some View {
        Button(action: sternAction) {
            VStack(spacing: 4) {
                Image(systemName: tarnEquipment.quirkIconName)
                    .font(.system(size: 20))
                    .foregroundColor(murkyIsSelected ? VexColorPalette.quellAccent : VexColorPalette.wharfTextSecondary)
                
                Text(tarnEquipment.tarnLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(murkyIsSelected ? VexColorPalette.wharfTextPrimary : VexColorPalette.wharfTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 24)
            }
            .frame(width: 72, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(murkyIsSelected ? VexColorPalette.fizzGlassCard : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(murkyIsSelected ? VexColorPalette.quellAccent : VexColorPalette.vexGlassBorder, lineWidth: murkyIsSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

