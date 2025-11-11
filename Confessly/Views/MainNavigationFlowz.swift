import SwiftUI

struct GradientBackgroundzView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.gradientLightTopz,
                Color.gradientDarkBottomz
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct MainNavigationFlowz: View {
    @StateObject private var viewModelz = PartyflowViewModel()
    
    var body: some View {
        ZStack {
            GradientBackgroundzView()
            
            switch viewModelz.currentPhazor {
            case .setupLaunch:
                LaunchpadView(viewModelz: viewModelz)
                    .transition(.opacity)
                
            case .playerTurnzFlip:
                TurnflipView(viewModelz: viewModelz)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .revealShowdown:
                ShowdownView(viewModelz: viewModelz)
                    .transition(.scale.combined(with: .opacity))
                
            case .gameFinale:
                FinaleView(viewModelz: viewModelz)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModelz.currentPhazor)
    }
}

