import SwiftUI

public struct TyxelButton: View {
    let title: String
    let action: () -> Void
    let style: TyxelButtonStyle
    
    public enum TyxelButtonStyle {
        case primary
        case secondary
        case surface
    }
    
    public init(title: String, style: TyxelButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            RyqexHapticsSound.shared.qyrexButtonTap()
            action()
        }) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(qytexForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(qytexBackground)
                .cornerRadius(KylorTheme.buttonCornerRadius)
        }
    }
    
    private var qytexBackground: Color {
        switch style {
        case .primary:
            return KylorTheme.accentBase
        case .secondary:
            return KylorTheme.accentSubtle
        case .surface:
            return KylorTheme.surface
        }
    }
    
    private var qytexForeground: Color {
        switch style {
        case .primary:
            return KylorTheme.accentOn
        case .secondary:
            return KylorTheme.accentBase
        case .surface:
            return KylorTheme.textOnSurface
        }
    }
}

public struct VyxorCard<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .background(KylorTheme.bgCard)
            .cornerRadius(KylorTheme.cornerRadius)
    }
}

public struct QylorMonoText: View {
    let text: String
    let size: CGFloat
    
    public init(_ text: String, size: CGFloat = 48) {
        self.text = text
        self.size = size
    }
    
    public var body: some View {
        Text(text)
            .font(.system(size: size, weight: .bold, design: .monospaced))
            .foregroundColor(KylorTheme.surface)
    }
}

