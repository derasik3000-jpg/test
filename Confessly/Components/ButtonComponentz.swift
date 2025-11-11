import SwiftUI

struct PrimaryCapsulezButton: View {
    let titlezText: String
    let actionz: () -> Void
    
    var body: some View {
        Button(action: {
            actionz()
        }) {
            Text(titlezText)
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [.primaryPinkz, .telemagentaz],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(SpringyButtonStylez())
    }
}

struct OptionCapsulezButton: View {
    let optionLabelz: String
    let optionTextz: String
    let actionz: () -> Void
    
    var body: some View {
        Button(action: {
            actionz()
        }) {
            VStack(spacing: 6) {
                Text(optionLabelz)
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.textSecondaryz)
                
                Text(optionTextz)
                    .font(.system(size: 19, weight: .bold, design: .default))
                    .foregroundColor(.textPrimaryz)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(Color.cardSurfacez)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.primaryPinkz.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(SpringyButtonStylez())
    }
}

struct SpringyButtonStylez: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct RoundedCardzView<Content: View>: View {
    let contentz: Content
    
    init(@ViewBuilder contentz: () -> Content) {
        self.contentz = contentz()
    }
    
    var body: some View {
        contentz
            .background(Color.cardSurfacez)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

