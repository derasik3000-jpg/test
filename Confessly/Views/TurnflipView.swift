import SwiftUI

struct TurnflipView: View {
    @ObservedObject var viewModelz: PartyflowViewModel
    @State private var flipAnimationz: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            ProgressDotziIndicator(
                totalDotzi: viewModelz.totalRoundzLimit,
                currentDotzi: viewModelz.currentRoundzIndex
            )
            .padding(.bottom, 20)
            
            Text("Round \(viewModelz.currentRoundzIndex + 1) of \(viewModelz.totalRoundzLimit)")
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(.textSecondaryz)
                .padding(.bottom, 30)
            
            VStack(spacing: 16) {
                Text("Now answering:")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(.textSecondaryz)
                
                Text(viewModelz.playerNamezArray[viewModelz.currentPlayerIndexz])
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.textPrimaryz)
            }
            .padding(.bottom, 30)
            
            if let promptzi = viewModelz.currentPromptzi {
                VStack(spacing: 0) {
                    RoundedCardzView {
                        VStack(spacing: 20) {
                            Text(promptzi.questionzText)
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.textPrimaryz)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .minimumScaleFactor(0.85)
                                .padding(.horizontal, 20)
                                .padding(.top, 30)
                                .padding(.bottom, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 140)
                    }
                    .padding(.horizontal, 24)
                    .rotation3DEffect(
                        .degrees(flipAnimationz ? 360 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    
                    Spacer().frame(height: 40)
                    
                    VStack(spacing: 16) {
                        OptionCapsulezButton(
                            optionLabelz: "Option A",
                            optionTextz: promptzi.optionAlpha,
                            actionz: {
                                viewModelz.recordPlayerChoicez(option: 0)
                            }
                        )
                        
                        OptionCapsulezButton(
                            optionLabelz: "Option B",
                            optionTextz: promptzi.optionBravo,
                            actionz: {
                                viewModelz.recordPlayerChoicez(option: 1)
                            }
                        )
                    }
                    .padding(.horizontal, 24)
                }
            }
            
            Spacer()
            
            if viewModelz.currentPlayerIndexz < viewModelz.playerCountzValue - 1 {
                Text("Pass device to next player")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.textSecondaryz)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                flipAnimationz = true
            }
        }
    }
}

