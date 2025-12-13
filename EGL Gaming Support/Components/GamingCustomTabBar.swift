import SwiftUI

struct GamingCustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house",
                title: "Spawn",
                isSelected: selectedTab == 0,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            TabBarButton(
                icon: "lightbulb",
                title: "Ideas",
                isSelected: selectedTab == 1,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            TabBarButton(
                icon: "gamecontroller",
                title: "Games",
                isSelected: selectedTab == 2,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
            
            TabBarButton(
                icon: "calendar",
                title: "Calendar",
                isSelected: selectedTab == 3,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 3
                }
            }
            
            TabBarButton(
                icon: "person",
                title: "Profile",
                isSelected: selectedTab == 4,
                animation: animation
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 4
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(GamingColorPalette.cardBackground)
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                GamingColorPalette.primaryPurple.opacity(0.6),
                                GamingColorPalette.primaryMagenta.opacity(0.5),
                                GamingColorPalette.primaryPurple.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
                    .blur(radius: 0.5)
            }
            .shadow(color: GamingColorPalette.primaryPurple.opacity(0.3), radius: 24, x: 0, y: 12)
            .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.15), radius: 15, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: isSelected ? 22 : 18, weight: isSelected ? .medium : .light))
                    .foregroundColor(isSelected ? GamingColorPalette.textOnAccent : GamingColorPalette.textSecondary)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .background(
                        Group {
                            if isSelected {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                GamingColorPalette.primaryPurple,
                                                GamingColorPalette.primaryMagenta
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .matchedGeometryEffect(id: "selectedTab", in: animation)
                                    .shadow(color: GamingColorPalette.primaryPurple.opacity(0.5), radius: 8, x: 0, y: 4)
                            }
                        }
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? GamingColorPalette.textPrimary : GamingColorPalette.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
