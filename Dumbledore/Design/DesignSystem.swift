// DesignSystem.swift
import SwiftUI

// MARK: - Color Palette
extension Color {
    // Base colors from RAL specification
    static let iWingBackground = Color(red: 0.780, green: 0.780, blue: 0.773) // #C7C7C5 - Telegrey 4
    static let iWingDeep = Color(red: 0.169, green: 0.227, blue: 0.267) // #2B3A44 - Grey Blue
    static let iWingAccent = Color(red: 0.0, green: 0.537, blue: 0.714) // #0089B6 - Light Blue
    static let iWingSurface = Color(red: 0.941, green: 0.937, blue: 0.914) // #F0EFE9 - Traffic White
    
    // Text colors
    static let iWingTextPrimary = Color(red: 0.169, green: 0.227, blue: 0.267) // #2B3A44
    static let iWingTextMuted = Color(red: 0.431, green: 0.478, blue: 0.514) // #6E7A83
    
    // Status colors
    static let iWingSuccess = Color(red: 0.561, green: 0.796, blue: 0.506) // #8FCB81
    static let iWingWarning = Color(red: 0.851, green: 0.553, blue: 0.482) // #D98D7B
    
    // Wave colors
    static let iWingWaveFill = Color(red: 0.0, green: 0.537, blue: 0.714, opacity: 0.25)
}

// MARK: - Gradients
extension LinearGradient {
    static let iWingBackground = LinearGradient(
        colors: [.iWingBackground, .iWingDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func iWingBackground(angle: Double) -> LinearGradient {
        // simple variation helper for angle feel
        LinearGradient(colors: [.iWingBackground, .iWingDeep], startPoint: .top, endPoint: .bottomTrailing)
    }
}

// MARK: - Typography
extension Font {
    static let iWingTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let iWingHeadline = Font.system(size: 22, weight: .semibold, design: .default)
    static let iWingBody = Font.system(size: 16, weight: .regular, design: .default)
    static let iWingCaption = Font.system(size: 14, weight: .medium, design: .default)
    static let iWingSmall = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing
extension CGFloat {
    static let iWingPadding: CGFloat = 16
    static let iWingPaddingSmall: CGFloat = 8
    static let iWingPaddingLarge: CGFloat = 24
    static let iWingCornerRadius: CGFloat = 12
    static let iWingCornerRadiusSmall: CGFloat = 8
}

// MARK: - Card Style
struct IWingCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.iWingSurface)
            .cornerRadius(.iWingCornerRadius)
            .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func iWingCard() -> some View {
        modifier(IWingCardStyle())
    }
}

// MARK: - Button Styles
struct IWingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.iWingTextPrimary)
            .padding(.horizontal, .iWingPadding)
            .padding(.vertical, 12)
            .background(Color.iWingSurface)
            .cornerRadius(.iWingCornerRadiusSmall)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IWingAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, .iWingPadding)
            .padding(.vertical, 12)
            .background(Color.iWingAccent)
            .cornerRadius(.iWingCornerRadiusSmall)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IWingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.iWingTextPrimary)
            .padding(.horizontal, .iWingPadding)
            .padding(.vertical, 12)
            .background(Color.iWingSurface.opacity(0.7))
            .cornerRadius(.iWingCornerRadiusSmall)
            .overlay(
                RoundedRectangle(cornerRadius: .iWingCornerRadiusSmall)
                    .stroke(Color.iWingAccent, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Chip Style
struct IWingChipStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.iWingAccent : Color.iWingSurface)
            .foregroundColor(isSelected ? .white : .iWingTextPrimary)
            .cornerRadius(16)
            .font(.iWingCaption)
    }
}

extension View {
    func iWingChip(isSelected: Bool = false) -> some View {
        modifier(IWingChipStyle(isSelected: isSelected))
    }
}
