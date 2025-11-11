import SwiftUI

struct FinaleView: View {
    @ObservedObject var viewModelz: PartyflowViewModel
    @State private var scaleEffectz: CGFloat = 0.5
    @State private var rotationAnglz: Double = -180
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))
                    .rotationEffect(.degrees(rotationAnglz))
                
                Text("Thanks for Playing!")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.textPrimaryz)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                
                Text("You completed \(viewModelz.totalRoundzLimit) rounds")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.textSecondaryz)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    RoundedCardzView {
                        VStack(spacing: 16) {
                            Text("Great memories made!")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.textPrimaryz)
                                .padding(.top, 20)
                            
                            Text("No data saved · Pure moment")
                                .font(.system(size: 13, weight: .medium, design: .default))
                                .foregroundColor(.textSecondaryz)
                                .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
            }
            .scaleEffect(scaleEffectz)
            
            Spacer()
            
            VStack(spacing: 14) {
                PrimaryCapsulezButton(
                    titlezText: "Play Again",
                    actionz: {
                        viewModelz.restartGameSessionz()
                    }
                )
                
                Button(action: {
                    viewModelz.restartGameSessionz()
                }) {
                    Text("Change Settings")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.textSecondaryz)
                        .frame(height: 50)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                scaleEffectz = 1.0
                rotationAnglz = 0
            }
        }
    }
}

