import SwiftUI

struct ShowdownView: View {
    @ObservedObject var viewModelz: PartyflowViewModel
    @State private var scaleAnimz: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            ProgressDotziIndicator(
                totalDotzi: viewModelz.totalRoundzLimit,
                currentDotzi: viewModelz.currentRoundzIndex
            )
            .padding(.bottom, 20)
            
            Text("Round \(viewModelz.currentRoundzIndex + 1) Results")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.textPrimaryz)
                .padding(.bottom, 30)
            
            if let promptzi = viewModelz.currentPromptzi {
                VStack(spacing: 24) {
                    RoundedCardzView {
                        VStack(spacing: 16) {
                            Text(promptzi.questionzText)
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.textPrimaryz)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                            
                            Divider()
                                .background(Color.neutralGreyz)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 20) {
                                VotezResultRowz(
                                    optionLabelz: "A",
                                    optionTextz: promptzi.optionAlpha,
                                    votezCount: viewModelz.getVotezCount().alphaVotez
                                )
                                
                                VotezResultRowz(
                                    optionLabelz: "B",
                                    optionTextz: promptzi.optionBravo,
                                    votezCount: viewModelz.getVotezCount().bravoVotez
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.horizontal, 24)
                    .scaleEffect(scaleAnimz)
                    
                    Text(viewModelz.getMajorityTextz())
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.primaryPinkz)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        ReactionBubblezi(emojiz: "❤️")
                        ReactionBubblezi(emojiz: "😂")
                        ReactionBubblezi(emojiz: "😮")
                    }
                    .padding(.top, 10)
                }
            }
            
            Spacer()
            
            PrimaryCapsulezButton(
                titlezText: "Next Round",
                actionz: {
                    viewModelz.proceedToNextRoundz()
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .overlay(
            Group {
                if viewModelz.showConfettiBlast {
                    ConfettiBurstViewz()
                }
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scaleAnimz = 1.0
            }
        }
    }
}

struct VotezResultRowz: View {
    let optionLabelz: String
    let optionTextz: String
    let votezCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text(optionLabelz)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.primaryPinkz)
                )
            
            Text(optionTextz)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(.textPrimaryz)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(votezCount)")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primaryPinkz)
                .frame(minWidth: 30)
        }
    }
}

struct ReactionBubblezi: View {
    let emojiz: String
    @State private var tappedz: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                tappedz = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    tappedz = false
                }
            }
        }) {
            Text(emojiz)
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(Color.cardSurfacez)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.neutralGreyz, lineWidth: 2)
                )
                .scaleEffect(tappedz ? 1.3 : 1.0)
        }
    }
}

