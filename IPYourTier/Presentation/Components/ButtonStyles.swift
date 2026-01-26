import SwiftUI

// MARK: - Primary Button Style (Gradient with glow)

public struct EnhancedPressHandler: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(ThemeColorsConfig.backgroundDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Gradient background
                    LinearGradient(
                        colors: [
                            ThemeColorsConfig.accentBright,
                            ThemeColorsConfig.accentBright.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Shine effect on top
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            )
            .cornerRadius(16)
            .shadow(
                color: ThemeColorsConfig.accentBright.opacity(0.4),
                radius: configuration.isPressed ? 8 : 15,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style (Outlined with glass effect)

public struct AlternateActionStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(ThemeColorsConfig.primaryLight)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                ZStack {
                    // Glass morphism background
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ThemeColorsConfig.backgroundCard.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                        )
                    
                    // Gradient border
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright.opacity(0.5),
                                    ThemeColorsConfig.accentBright.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 1 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style (Minimal)

public struct TertiaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(ThemeColorsConfig.accentBright)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeColorsConfig.accentBright.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColorsConfig.accentBright.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Press Events Helper (for custom press animations)

public struct PressEventsModifier: ViewModifier {
    public var onPress: () -> Void
    public var onRelease: () -> Void
    
    @GestureState private var isDetectingLongPress = false
    
    public init(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) {
        self.onPress = onPress
        self.onRelease = onRelease
    }
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                LongPressGesture(minimumDuration: 0.0)
                    .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                        if currentState && !gestureState {
                            onPress()
                        }
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

// MARK: - Extensions

extension Button {
    public func primaryStyleConfig() -> some View {
        self.buttonStyle(EnhancedPressHandler())
    }
    
    public func secondaryStyleConfig() -> some View {
        self.buttonStyle(AlternateActionStyle())
    }
    
    public func tertiaryStyleConfig() -> some View {
        self.buttonStyle(TertiaryButtonStyle())
    }
}

extension View {
    public func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

