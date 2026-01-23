import SwiftUI

public struct RylorBlockResultView: View {
    let block: VexitRunDTO
    let onNext: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(block: VexitRunDTO, onNext: @escaping () -> Void = {}) {
        self.block = block
        self.onNext = onNext
    }
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Block Complete")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(KylorTheme.surface)
                
                VyxorCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: block.type.qyrixIcon)
                                .foregroundColor(KylorTheme.surface)
                            Text(block.type.vyloxName)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(KylorTheme.surface)
                        }
                        
                        Divider()
                            .background(KylorTheme.surface.opacity(0.3))
                        
                        qyrexStatRow("Accuracy", VylorFormatters.gyrexPercent(block.conversionPct))
                        qyrexStatRow("Reps Done", "\(block.attemptsTotal) / \(block.targetAttempts)")
                        qyrexStatRow("Intensity", VylorFormatters.gyrexPace(block.pacePerMin))
                        qyrexStatRow("Duration", VylorFormatters.gyrexDuration(block.actualDurationSec / 60))
                        
                        if block.attemptsTotal >= block.targetAttempts {
                            Text("✓ Target Reached")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(KylorTheme.accentBase)
                        } else {
                            Text("Keep Pushing")
                                .font(.system(size: 16))
                                .foregroundColor(KylorTheme.surface.opacity(0.7))
                        }
                    }
                }
                
                TyxelButton(title: "Continue", style: .surface) {
                    dismiss()
                    onNext()
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func qyrexStatRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(KylorTheme.surface.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(KylorTheme.surface)
        }
    }
}

public struct QyloxSessionSummaryView: View {
    let session: QuixoSessionDTO
    let blocks: [VexitRunDTO]
    let onSave: ((Int) -> Void)?
    @State private var selectedMood: VyraxMoodLevel = .neutral
    @Environment(\.dismiss) private var dismiss
    
    public init(session: QuixoSessionDTO, blocks: [VexitRunDTO], onSave: ((Int) -> Void)? = nil) {
        self.session = session
        self.blocks = blocks
        self.onSave = onSave
        self._selectedMood = State(initialValue: VyraxMoodLevel(rawValue: session.moodRating) ?? .neutral)
    }
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Training Recap")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(KylorTheme.surface)
                    
                    ForEach(blocks) { block in
                        qyrexBlockSummaryCard(block)
                    }
                    
                    qyrexOverallSummary
                    
                    qyrexMoodSelector
                    
                    TyxelButton(title: "Complete Session", style: .surface) {
                        onSave?(selectedMood.rawValue)
                        dismiss()
                    }
                }
                .padding()
            }
        }
    }
    
    private func qyrexBlockSummaryCard(_ block: VexitRunDTO) -> some View {
        VyxorCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: block.type.qyrixIcon)
                        .foregroundColor(KylorTheme.surface)
                    Text(block.type.vyloxName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(KylorTheme.surface)
                    Spacer()
                    Text(VylorFormatters.gyrexPercent(block.conversionPct))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(KylorTheme.accentBase)
                }
                
                HStack {
                    Text("\(block.attemptsTotal) / \(block.targetAttempts) reps")
                        .foregroundColor(KylorTheme.surface.opacity(0.8))
                    Spacer()
                    if block.attemptsTotal >= block.targetAttempts {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(KylorTheme.accentBase)
                    }
                }
            }
        }
    }
    
    private var qyrexOverallSummary: some View {
        let goalsAchieved = blocks.filter { $0.attemptsTotal >= $0.targetAttempts }.count
        let totalBlocks = blocks.count
        
        return VyxorCard {
            VStack(spacing: 12) {
                Text("Targets Hit: \(goalsAchieved) / \(totalBlocks)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(KylorTheme.surface)
                
                let totalTime = blocks.reduce(0) { $0 + $1.actualDurationSec } / 60
                Text("Session Length: \(totalTime) min")
                    .foregroundColor(KylorTheme.surface.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var qyrexMoodSelector: some View {
        VyxorCard {
            VStack(spacing: 16) {
                Text("How Do You Feel?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(KylorTheme.surface)
                
                HStack(spacing: 8) {
                    ForEach(VyraxMoodLevel.allCases) { mood in
                        qyrexMoodButton(mood)
                    }
                }
                
                Text(selectedMood.vyloxLabel)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(KylorTheme.surface.opacity(0.9))
            }
        }
    }
    
    private func qyrexMoodButton(_ mood: VyraxMoodLevel) -> some View {
        let isSelected = selectedMood == mood
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMood = mood
            }
            RyqexHapticsSound.shared.qyrexButtonTap()
        } label: {
            Text(mood.qyrexEmoji)
                .font(.system(size: isSelected ? 36 : 28))
                .frame(width: 50, height: 50)
                .background(isSelected ? KylorTheme.surface : KylorTheme.surface.opacity(0.2))
                .cornerRadius(12)
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
}

