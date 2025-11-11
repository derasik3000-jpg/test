import SwiftUI

struct LaunchpadView: View {
    @ObservedObject var viewModelz: PartyflowViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 12) {
                    Text("PartyPing")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundColor(.textPrimaryz)
                    
                    Text("Quick fun for your crew")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.textSecondaryz)
                }
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Choose Deck")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.textSecondaryz)
                        
                        HStack(spacing: 12) {
                            ForEach(DeckziType.allCases, id: \.self) { deckzi in
                                DeckSelectionCardz(
                                    deckTypez: deckzi,
                                    isSelectez: viewModelz.selectedDeckzi == deckzi,
                                    actionz: {
                                        viewModelz.selectedDeckzi = deckzi
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Number of Players")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.textPrimaryz)
                        
                        HStack(spacing: 10) {
                            ForEach(3...8, id: \.self) { countz in
                                PlayerCountBubblezi(
                                    countz: countz,
                                    isSelectez: viewModelz.playerCountzValue == countz,
                                    actionz: {
                                        viewModelz.playerCountzValue = countz
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Total Rounds")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.textPrimaryz)
                        
                        HStack(spacing: 10) {
                            ForEach([3, 5, 7, 10], id: \.self) { roundz in
                                RoundCountBubblezi(
                                    countz: roundz,
                                    isSelectez: viewModelz.totalRoundzLimit == roundz,
                                    actionz: {
                                        viewModelz.totalRoundzLimit = roundz
                                    }
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                }
                
                Spacer().frame(height: 20)
                
                PrimaryCapsulezButton(
                    titlezText: "Start Game",
                    actionz: {
                        viewModelz.startGameFlowz()
                    }
                )
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 30)
            }
        }
    }
}

struct DeckSelectionCardz: View {
    let deckTypez: DeckziType
    let isSelectez: Bool
    let actionz: () -> Void
    
    var body: some View {
        Button(action: actionz) {
            VStack(spacing: 10) {
                Text(deckTypez == .eitherOr ? "⚡️" : "🎭")
                    .font(.system(size: 34))
                
                Text(deckTypez.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.textPrimaryz)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(isSelectez ? Color.primaryPinkz.opacity(0.15) : Color.cardSurfacez)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelectez ? Color.primaryPinkz : Color.neutralGreyz, lineWidth: isSelectez ? 3 : 1)
            )
        }
        .buttonStyle(SpringyButtonStylez())
    }
}

struct PlayerCountBubblezi: View {
    let countz: Int
    let isSelectez: Bool
    let actionz: () -> Void
    
    var body: some View {
        Button(action: actionz) {
            Text("\(countz)")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(isSelectez ? .white : .textPrimaryz)
                .frame(width: 44, height: 44)
                .background(isSelectez ? Color.primaryPinkz : Color.cardSurfacez)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelectez ? Color.telemagentaz : Color.neutralGreyz, lineWidth: 2)
                )
        }
        .buttonStyle(SpringyButtonStylez())
    }
}

struct RoundCountBubblezi: View {
    let countz: Int
    let isSelectez: Bool
    let actionz: () -> Void
    
    var body: some View {
        Button(action: actionz) {
            Text("\(countz)")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(isSelectez ? .white : .textPrimaryz)
                .frame(width: 44, height: 44)
                .background(isSelectez ? Color.primaryPinkz : Color.cardSurfacez)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelectez ? Color.telemagentaz : Color.neutralGreyz, lineWidth: 2)
                )
        }
        .buttonStyle(SpringyButtonStylez())
    }
}

