import SwiftUI

public struct QuirkDetailSheet: View {
    let replacement: FizzReplacementModel
    let onApplied: () -> Void
    
    @StateObject private var fizzVM: PlinthDetailViewModel
    @Environment(\.dismiss) private var murkyDismiss
    
    public init(replacement: FizzReplacementModel, onApplied: @escaping () -> Void) {
        self.replacement = replacement
        self.onApplied = onApplied
        
        let context = QuirkCoreDataStack.shared.fizzContext
        let logRepo = QuellAppliedLogRepositoryImpl(fizzContext: context)
        let dateProvider = SternDefaultDateProvider()
        let haptics = PlinthDefaultHaptics()
        let applyUC = WharfDefaultApplyReplacementToday(
            tarnLogRepo: logRepo,
            plinthDateProvider: dateProvider,
            quirkHaptics: haptics
        )
        let exporter = QuellDefaultTextExporter()
        
        let vm = PlinthDetailViewModel(
            replacement: replacement,
            sternApplyUC: applyUC,
            wharfExporter: exporter
        )
        _fizzVM = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        ZStack {
            VexColorPalette.brindleBrandDark
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    VexColorPalette.murkyGradientEnd,
                    VexColorPalette.murkyGradientStart
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(VexColorPalette.wharfTextSecondary)
                        
                        Text(replacement.tarnATitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(VexColorPalette.wharfTextPrimary)
                        
                        Divider().background(VexColorPalette.sternDivider)
                        
                        Text("Do:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(VexColorPalette.wharfTextSecondary)
                        
                        Text(replacement.tarnBTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(VexColorPalette.wharfTextPrimary)
                        
                        Text(replacement.quellEquiv.plinthDisplayText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(VexColorPalette.quellAccent)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(VexColorPalette.fizzGlassCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                            )
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Variants")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(VexColorPalette.wharfTextPrimary)
                        
                        ForEach(replacement.quirkVariants) { variant in
                                Button(action: {
                                    fizzVM.vexSelectedVariant = variant
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: fizzVM.vexSelectedVariant?.id == variant.id ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(fizzVM.vexSelectedVariant?.id == variant.id ? VexColorPalette.quellAccent : VexColorPalette.wharfTextSecondary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(variant.tarnTitle)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                            
                                            if let detail = variant.tarnDetail {
                                                Text(detail)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(VexColorPalette.wharfTextSecondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        ForEach(Array(variant.plinthEquipment.prefix(2)), id: \.self) { equip in
                                            Image(systemName: equip.quirkIconName)
                                                .font(.system(size: 14))
                                                .foregroundColor(VexColorPalette.wharfTextSecondary)
                                        }
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(fizzVM.vexSelectedVariant?.id == variant.id ? VexColorPalette.fizzGlassCard : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(fizzVM.vexSelectedVariant?.id == variant.id ? VexColorPalette.quellAccent : VexColorPalette.sternDivider, lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    
                    HStack(spacing: 6) {
                        ForEach(Array(replacement.wharfTags), id: \.self) { tag in
                                Text(tag.plinthLabel)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(VexColorPalette.brindleBrandDark)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(VexColorPalette.plinthGoalColor(tag))
                                    )
                            }
                            
                            Spacer()
                            
                            Text(replacement.brindleDifficulty.tarnLabel)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(VexColorPalette.tarnDifficultyColor(replacement.brindleDifficulty).opacity(0.3))
                                )
                    }
                    
                    VStack(spacing: 10) {
                        TextField("Add note (optional, max 120 chars)", text: $fizzVM.tarnNote, axis: .vertical)
                                .textFieldStyle(.plain)
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(VexColorPalette.fizzGlassCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                                        )
                                )
                                .lineLimit(3...4)
                            
                            if let validation = fizzVM.murkyValidation {
                                Text(validation)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#E05252"))
                            }
                    }
                    
                    Button(action: {
                        fizzVM.fizzApplyToday()
                    }) {
                        HStack {
                            if fizzVM.brindleIsApplying {
                                ProgressView()
                                    .tint(VexColorPalette.brindleBrandDark)
                                    .scaleEffect(0.8)
                            }
                            Text(fizzVM.brindleIsApplying ? "Applying..." : "Apply Today")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(VexColorPalette.brindleBrandDark)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(VexColorPalette.plinthPrimaryButton)
                        )
                    }
                    .disabled(fizzVM.brindleIsApplying)
                    .buttonStyle(.plain)
                        
                        TarnSecondaryButton(plinthTitle: "Share") {
                            let text = fizzVM.tarnExportText()
                            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                rootVC.present(activityVC, animated: true)
                            }
                    }
                }
                .padding(16)
            }
        }
        .quirkSheetBackground()
        .onAppear {
            fizzVM.quellOnApplied = onApplied
        }
    }
}

