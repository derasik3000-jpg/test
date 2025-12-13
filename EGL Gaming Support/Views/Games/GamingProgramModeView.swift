import SwiftUI

struct GamingProgramModeView: View {
    @ObservedObject var viewModel: GamingGamesViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GamingGradientBackgroundView()
                
                if let program = viewModel.activeProgram,
                   viewModel.currentStepIndex < program.steps.count {
                    let step = program.steps[viewModel.currentStepIndex]
                    
                    VStack(spacing: 32) {
                        Spacer()
                        
                        GamingGlassmorphismPanel {
                            VStack(spacing: 24) {
                                Text("Step \(viewModel.currentStepIndex + 1) of \(program.steps.count)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(GamingColorPalette.textSecondary)
                                
                                Text(program.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(GamingColorPalette.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Level")
                                            .font(.system(size: 14))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        Text(step.level)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Rank")
                                            .font(.system(size: 14))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        Text(step.rank)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Action")
                                            .font(.system(size: 14))
                                            .foregroundColor(GamingColorPalette.textSecondary)
                                        Text(step.action)
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        viewModel.skipStep()
                                    }) {
                                        Text("Skip")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(GamingColorPalette.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(GamingColorPalette.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(GamingColorPalette.primaryPurple.opacity(0.5), lineWidth: 1)
                                            )
                                            .cornerRadius(12)
                                    }
                                    
                                    Button(action: {
                                        viewModel.completeCurrentStep()
                                    }) {
                                        Text("Complete")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(GamingColorPalette.textOnAccent)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        GamingColorPalette.primaryPurple,
                                                        GamingColorPalette.primaryMagenta
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                } else {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 80, weight: .ultraLight))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        GamingColorPalette.primaryPurple,
                                        GamingColorPalette.primaryMagenta
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Program Complete!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(GamingColorPalette.textPrimary)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(GamingColorPalette.textOnAccent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            GamingColorPalette.primaryPurple,
                                            GamingColorPalette.primaryMagenta
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
