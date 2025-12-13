import SwiftUI

struct GamingSearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search"
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(GamingColorPalette.primaryPurple)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(GamingColorPalette.textPrimary)
                .tint(GamingColorPalette.primaryPurple)
                .accentColor(GamingColorPalette.primaryPurple)
                .onAppear {
                    UITextField.appearance().attributedPlaceholder = NSAttributedString(
                        string: placeholder,
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(GamingColorPalette.textSecondary)]
                    )
                }
            
            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(GamingColorPalette.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(GamingColorPalette.cardBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                GamingColorPalette.primaryPurple.opacity(0.5),
                                GamingColorPalette.primaryMagenta.opacity(0.4)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
                    .blur(radius: 0.3)
            }
            .shadow(color: GamingColorPalette.primaryPurple.opacity(0.15), radius: 12, x: 0, y: 5)
        )
    }
}

struct GamingScreenHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(GamingColorPalette.textPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(GamingColorPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GamingFABButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                GamingColorPalette.primaryPurple.opacity(0.4),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 45
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)
                
                // Main button with purple gradient
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
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(GamingColorPalette.textOnAccent)
            }
            .shadow(color: GamingColorPalette.primaryPurple.opacity(0.5), radius: 15, x: 0, y: 8)
            .shadow(color: GamingColorPalette.primaryMagenta.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
