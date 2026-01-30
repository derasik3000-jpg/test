import SwiftUI

public struct BrindleFiltersScreen: View {
    @StateObject private var plinthVM: QuellFiltersViewModel
    
    public init(plinthVM: QuellFiltersViewModel) {
        _plinthVM = StateObject(wrappedValue: plinthVM)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                SternGradientBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Filters")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(VexColorPalette.quellAccent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goals")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(VexGoalTag.allCases) { tag in
                                    WharfGoalTagChip(
                                        quirkTag: tag,
                                        vexIsSelected: plinthVM.fizzTags.contains(tag)
                                    ) {
                                        if plinthVM.fizzTags.contains(tag) {
                                            plinthVM.fizzTags.remove(tag)
                                        } else {
                                            plinthVM.fizzTags.insert(tag)
                                        }
                                        plinthVM.sternSave()
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Equipment")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(PlinthEquipment.allCases) { equip in
                                    FizzEquipmentChip(
                                        tarnEquipment: equip,
                                        murkyIsSelected: plinthVM.wharfEquip.contains(equip)
                                    ) {
                                        if plinthVM.wharfEquip.contains(equip) {
                                            plinthVM.wharfEquip.remove(equip)
                                        } else {
                                            plinthVM.wharfEquip.insert(equip)
                                        }
                                        plinthVM.sternSave()
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(SternDurationBand.allCases) { band in
                                    Button(action: {
                                        if plinthVM.plinthBands.contains(band) {
                                            plinthVM.plinthBands.remove(band)
                                        } else {
                                            plinthVM.plinthBands.insert(band)
                                        }
                                        plinthVM.sternSave()
                                    }) {
                                        Text(band.tarnLabel)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(plinthVM.plinthBands.contains(band) ? VexColorPalette.brindleBrandDark : VexColorPalette.wharfTextPrimary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(plinthVM.plinthBands.contains(band) ? VexColorPalette.quellAccent : VexColorPalette.fizzGlassCard)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(plinthVM.plinthBands.contains(band) ? VexColorPalette.quellAccent : VexColorPalette.vexGlassBorder, lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        Spacer().frame(height: 20)
                        
                        MurkyPrimaryButton(quellTitle: "Save Filters") {
                            plinthVM.sternSave()
                        }
                        
                        TarnSecondaryButton(plinthTitle: "Reset All") {
                            plinthVM.murkyReset()
                        }
                    }
                    .padding(16)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, row) in result.rows.enumerated() {
            var x = bounds.minX
            let y = bounds.minY + result.rowHeights.prefix(index).reduce(0, +) + CGFloat(index) * spacing
            
            for subviewIndex in row {
                let subview = subviews[subviewIndex]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var rows: [[Int]] = [[]]
        var rowHeights: [CGFloat] = [0]
        var height: CGFloat = 0
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                    rows.append([])
                    rowHeights.append(0)
                    x = 0
                }
                
                rows[rows.count - 1].append(index)
                rowHeights[rowHeights.count - 1] = max(rowHeights[rowHeights.count - 1], size.height)
                x += size.width + spacing
            }
            
            height = rowHeights.reduce(0, +) + CGFloat(max(0, rowHeights.count - 1)) * spacing
        }
    }
}

