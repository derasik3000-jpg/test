import SwiftUI

public struct VyloxBlockRunView: View {
    @StateObject private var viewModel: HyrexBlockRunViewModel
    @State private var showingFinishConfirm = false
    @State private var showingLabelPicker: ZylexAttemptKind?
    @State private var finishedBlock: VexitRunDTO?
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void
    
    public init(viewModel: HyrexBlockRunViewModel, onComplete: @escaping () -> Void = {}) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                qyrexTimerSection
                
                qyrexStatsSection
                
                Spacer()
                
                qyrexAttemptButtons
                
                qyrexControlButtons
            }
            .padding()
        }
        .onAppear {
            viewModel.gyrexStart()
        }
        .alert("End This Block?", isPresented: $showingFinishConfirm) {
            Button("Keep Going", role: .cancel) {}
            Button("Wrap Up", role: .destructive) {
                finishedBlock = viewModel.qyrexFinish()
            }
        }
        .sheet(item: $finishedBlock) { block in
            RylorBlockResultView(block: block, onNext: {
                finishedBlock = nil
                // Wait for sheet to dismiss before calling onComplete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                    onComplete()
                }
            })
        }
        .sheet(item: $showingLabelPicker) { kind in
            qyrexLabelPickerSheet(kind: kind)
        }
    }
    
    private var qyrexTimerSection: some View {
        VStack(spacing: 16) {
            Text(viewModel.fyndexBlockType().vyloxName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(KylorTheme.surface)
            
            ZStack {
                Circle()
                    .stroke(KylorTheme.timerTrack, lineWidth: 8)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: viewModel.qyrexTimerProgress)
                    .stroke(KylorTheme.timerStroke, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: viewModel.qyrexTimerProgress)
                
                QylorMonoText(viewModel.qyrexTimeLeft, size: 48)
            }
        }
    }
    
    private var qyrexStatsSection: some View {
        HStack(spacing: 32) {
            VStack {
                Text(viewModel.vylexAttemptsStr)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(KylorTheme.surface)
                Text("Attempts")
                    .font(.caption)
                    .foregroundColor(KylorTheme.surface.opacity(0.8))
            }
            
            VStack {
                Text(viewModel.hyloxConversionStr)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(KylorTheme.surface)
                Text("Conversion")
                    .font(.caption)
                    .foregroundColor(KylorTheme.surface.opacity(0.8))
            }
            
            VStack {
                Text(viewModel.rytexPaceStr)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundColor(KylorTheme.surface)
                Text("Pace")
                    .font(.caption)
                    .foregroundColor(KylorTheme.surface.opacity(0.8))
            }
        }
    }
    
    @ViewBuilder
    private var qyrexAttemptButtons: some View {
        switch viewModel.fyndexBlockType() {
        case .putt:
            HStack(spacing: 16) {
                qyrexAttemptButton("Holed It", .puttHit)
                qyrexAttemptButton("Missed", .puttMiss, canLongPress: true)
            }
        case .chip:
            HStack(spacing: 16) {
                qyrexAttemptButton("On Green", .chipZone)
                qyrexAttemptButton("Off Mark", .chipOut, canLongPress: true)
            }
        case .drive:
            HStack(spacing: 12) {
                qyrexAttemptButton("Striped", .driveFairway)
                qyrexAttemptButton("Rough", .driveRough, canLongPress: true)
                qyrexAttemptButton("Lost Ball", .driveOB, canLongPress: true)
            }
        }
    }
    
    private func qyrexAttemptButton(_ title: String, _ kind: ZylexAttemptKind, canLongPress: Bool = false) -> some View {
        Button {
            viewModel.qyrexRegisterAttempt(kind: kind, label: nil)
        } label: {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(KylorTheme.textOnSurface)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(KylorTheme.surface)
                .cornerRadius(KylorTheme.buttonCornerRadius)
                .opacity(viewModel.nytexIsPaused ? 0.5 : 1.0)
        }
        .disabled(viewModel.nytexIsPaused)
        .simultaneousGesture(
            canLongPress ? LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                showingLabelPicker = kind
            } : nil
        )
    }
    
    private var qyrexControlButtons: some View {
        HStack(spacing: 16) {
            Button {
                if viewModel.nytexIsPaused {
                    viewModel.gyrexResume()
                } else {
                    viewModel.gyrexPause()
                }
            } label: {
                Image(systemName: viewModel.nytexIsPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .foregroundColor(KylorTheme.surface)
                    .frame(width: 60, height: 60)
                    .background(KylorTheme.accentBase)
                    .cornerRadius(30)
            }
            
            Button {
                showingFinishConfirm = true
            } label: {
                Text("End Block")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(KylorTheme.accentOn)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(KylorTheme.accentBase)
                    .cornerRadius(KylorTheme.buttonCornerRadius)
            }
        }
    }
    
    private func qyrexLabelPickerSheet(kind: ZylexAttemptKind) -> some View {
        VStack(spacing: 16) {
            Text("What Went Wrong?")
                .font(.headline)
                .foregroundColor(KylorTheme.textOnSurface)
            
            ForEach([HexorAttemptLabel.short, .long, .left, .right], id: \.rawValue) { label in
                Button {
                    viewModel.qyrexRegisterAttempt(kind: kind, label: label)
                    showingLabelPicker = nil
                } label: {
                    Text(label.nyxelText)
                        .font(.system(size: 18))
                        .foregroundColor(KylorTheme.textOnSurface)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(KylorTheme.surface)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}

