import SwiftUI

struct BreathFlowConductorView: View {
    @ObservedObject var viewModel: BreathFlowConductorViewModel
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @Environment(\.presentationMode) var presentationMode
    @State private var showSoundOptions = false
    
    var body: some View {
        ZStack {
            LinearGradient.celestialBackdrop
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: {
                        viewModel.concludeFlow()
                        orchestrator.navigateTo(.mainNexus)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.shadowText)
                            .frame(width: 36, height: 36)
                            .background(Color.pureEssence.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(viewModel.flowCategory.displayNomenclature)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.shadowText)
                    
                    Spacer()
                    
                    Button(action: {
                        showSoundOptions.toggle()
                    }) {
                        Image(systemName: viewModel.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.shadowText)
                            .frame(width: 36, height: 36)
                            .background(Color.pureEssence.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.nebulaBlossom.opacity(0.4), Color.lavenderMist.opacity(0.3)],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 280, height: 280)
                        .blur(radius: 20)
                        .scaleEffect(viewModel.breathCycleScale)
                    
                    Circle()
                        .stroke(Color.nebulaBlossom.opacity(0.5), lineWidth: 2)
                        .frame(width: 220, height: 220)
                        .scaleEffect(viewModel.breathCycleScale)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.nebulaBlossom.opacity(0.6), Color.lavenderMist.opacity(0.4)],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(viewModel.breathCycleScale)
                }
                .animation(.easeInOut(duration: 1.0), value: viewModel.breathCycleScale)
                
                VStack(spacing: 12) {
                    Text(viewModel.currentInstruction)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.shadowText)
                    
                    Text(formatTime(viewModel.totalElapsedSeconds))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.shadowText.opacity(0.6))
                }
                
                ProgressView(value: viewModel.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .nebulaBlossom))
                    .frame(width: 200)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Spacer()
                
                HStack(spacing: 20) {
                    if viewModel.isActiveCeremony {
                        Button(action: {
                            viewModel.togglePauseState()
                        }) {
                            Image(systemName: viewModel.isPausedState ? "play.fill" : "pause.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.pureEssence)
                                .frame(width: 70, height: 70)
                                .background(Color.nebulaBlossom)
                                .clipShape(Circle())
                                .shadow(color: Color.nebulaBlossom.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            viewModel.concludeFlow()
                            orchestrator.navigateTo(.mainNexus)
                        }) {
                            Text("End Session")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.shadowText)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(Color.pureEssence.opacity(0.7))
                                .cornerRadius(35)
                        }
                    } else {
                        Button(action: {
                            viewModel.initiateFlow()
                        }) {
                            Text("Begin")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.pureEssence)
                                .frame(width: 160, height: 60)
                                .background(Color.nebulaBlossom)
                                .cornerRadius(30)
                                .shadow(color: Color.nebulaBlossom.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSoundOptions) {
            SoundOptionsSheet(viewModel: viewModel)
        }
        .navigationBarHidden(true)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct SoundOptionsSheet: View {
    @ObservedObject var viewModel: BreathFlowConductorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.celestialBackdrop
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Toggle("Enable Sound", isOn: Binding(
                        get: { viewModel.soundEnabled },
                        set: { _ in viewModel.toggleSound() }
                    ))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.pureEssence.opacity(0.7))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .tint(.nebulaBlossom)
                    
                    if viewModel.soundEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ambient Sound")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.shadowText)
                                .padding(.horizontal, 20)
                            
                            ForEach(AmbientSoundType.allCases) { sound in
                                Button(action: {
                                    viewModel.changeAmbientSound(sound)
                                }) {
                                    HStack {
                                        Image(systemName: sound == .none ? "speaker.slash" : "speaker.wave.2")
                                            .font(.system(size: 18))
                                            .foregroundColor(.nebulaBlossom)
                                            .frame(width: 30)
                                        
                                        Text(sound.rawValue)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.shadowText)
                                        
                                        Spacer()
                                        
                                        if viewModel.selectedAmbientSound == sound {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.nebulaBlossom)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.pureEssence.opacity(0.7))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Background Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.nebulaBlossom)
                }
            }
        }
    }
}

