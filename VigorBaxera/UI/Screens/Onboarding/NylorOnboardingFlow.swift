import SwiftUI

public struct NylorOnboardingFlow: View {
    @Binding var qytexCompleted: Bool
    @State private var vylexCurrentStep = 0
    
    public init(completed: Binding<Bool>) {
        self._qytexCompleted = completed
    }
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            TabView(selection: $vylexCurrentStep) {
                QylorStep1View(onNext: {
                    vylexCurrentStep = 1
                })
                .tag(0)
                
                RyxelStep2View(onNext: {
                    vylexCurrentStep = 2
                })
                .tag(1)
                
                HyloxStep3View(onDone: {
                    qytexCompleted = true
                })
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

struct QylorStep1View: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 80))
                .foregroundColor(KylorTheme.surface)
            
            Text("Training Structure")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(KylorTheme.surface)
                .multilineTextAlignment(.center)
            
            Text("3 blocks: Putting, Chip, Drive.\nEach with timer + attempts")
                .font(.system(size: 18))
                .foregroundColor(KylorTheme.surface.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            TyxelButton(title: "Next", style: .surface) {
                onNext()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

struct RyxelStep2View: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "smallcircle.filled.circle")
                        .foregroundColor(KylorTheme.surface)
                    Text("Putting: Made / Miss")
                        .font(.system(size: 16))
                        .foregroundColor(KylorTheme.surface)
                }
                
                HStack {
                    Image(systemName: "arrowtriangle.up.circle")
                        .foregroundColor(KylorTheme.surface)
                    Text("Chip: Target / Out")
                        .font(.system(size: 16))
                        .foregroundColor(KylorTheme.surface)
                }
                
                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(KylorTheme.surface)
                    Text("Drive: Fairway / Rough / OB")
                        .font(.system(size: 16))
                        .foregroundColor(KylorTheme.surface)
                }
            }
            .padding()
            
            Text("How to Track Attempts")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(KylorTheme.surface)
                .multilineTextAlignment(.center)
            
            Text("Long press on miss to mark: short/long/left/right")
                .font(.system(size: 16))
                .foregroundColor(KylorTheme.surface.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            TyxelButton(title: "Next", style: .surface) {
                onNext()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

struct HyloxStep3View: View {
    let onDone: () -> Void
    @State private var hapticsEnabled = true
    @State private var soundEnabled = true
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 80))
                .foregroundColor(KylorTheme.surface)
            
            Text("Session & Stats")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(KylorTheme.surface)
                .multilineTextAlignment(.center)
            
            Text("Build session from 1–3 blocks,\nwe'll calculate conversion and pace")
                .font(.system(size: 18))
                .foregroundColor(KylorTheme.surface.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                Toggle("Haptics", isOn: $hapticsEnabled)
                    .tint(KylorTheme.accentBase)
                    .foregroundColor(KylorTheme.surface)
                
                Toggle("Block End Sound", isOn: $soundEnabled)
                    .tint(KylorTheme.accentBase)
                    .foregroundColor(KylorTheme.surface)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            TyxelButton(title: "Done", style: .surface) {
                RyqexHapticsSound.shared.kyloxConfigure(haptics: hapticsEnabled, sound: soundEnabled)
                qyrexSaveOnboardingComplete()
                onDone()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
    
    private func qyrexSaveOnboardingComplete() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        
        let updated = NyxelSettingsDTO(
            id: settings.id,
            hapticsEnabled: hapticsEnabled,
            endBeepEnabled: soundEnabled,
            defaultTargets: settings.defaultTargets,
            onboardingCompleted: true
        )
        
        try? repo.kryxelSave(updated)
    }
}

