import SwiftUI

public struct CheckStartView: View {
    @ObservedObject var viewModel: CheckFlowVM
    
    public init(viewModel: CheckFlowVM) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Select Area")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Where are you experiencing symptoms?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(ZoneDTO.allCases) { zone in
                        ZoneCardView(
                            zone: zone,
                            isSelected: viewModel.selectedZone == zone
                        ) {
                            print("🔹 Selected zone tapped: \(zone.rawValue) \(zone.displayName)")
                            viewModel.selectedZone = zone
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, viewModel.selectedZone != nil ? 120 : 20)
            }
            
            if viewModel.selectedZone != nil {
                VStack(spacing: 8) {
                    Button {
                        print("🔥 BUTTON TAPPED!")
                        guard let zone = viewModel.selectedZone else {
                            print("❌ No zone selected")
                            return
                        }
                        print("🔸 Start pressed with zone: \(zone.rawValue) \(zone.displayName)")
                        viewModel.startCheck(zone: zone)
                        print("✅ startCheck called")
                    } label: {
                        HStack {
                            Text("Start Check")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .primaryStyleConfig()
                    
                    Text("Takes ~30 seconds")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    Rectangle()
                        .fill(ThemeColorsConfig.backgroundDeep.opacity(0.95))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}

struct ZoneCardView: View {
    let zone: ZoneDTO
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 10) {
                // Icon with glow effect when selected
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(ThemeColorsConfig.accentBright.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .blur(radius: 8)
                    }
                    
                    Image(systemName: zone.iconName)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(isSelected ? ThemeColorsConfig.accentBright : ThemeColorsConfig.primaryLight.opacity(0.8))
                        .shadow(color: isSelected ? ThemeColorsConfig.accentBright.opacity(0.5) : .clear, radius: 8, x: 0, y: 2)
                }
                
                Text(zone.displayName)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? ThemeColorsConfig.accentBright : ThemeColorsConfig.primaryLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 95)
            .background(
                ZStack {
                    // Base background with glass effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isSelected 
                            ? ThemeColorsConfig.backgroundCard.opacity(0.8)
                            : ThemeColorsConfig.backgroundCard.opacity(0.5)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    
                    // Gradient overlay when selected
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        ThemeColorsConfig.accentBright.opacity(0.15),
                                        ThemeColorsConfig.accentBright.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // Border
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected 
                            ? LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright,
                                    ThemeColorsConfig.accentBright.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    ThemeColorsConfig.neutralMuted.opacity(0.3),
                                    ThemeColorsConfig.neutralMuted.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .shadow(
                color: isSelected ? ThemeColorsConfig.accentBright.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 6 : 3
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = false
            }
        }
        .accessibilityLabel(zone.displayName)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

