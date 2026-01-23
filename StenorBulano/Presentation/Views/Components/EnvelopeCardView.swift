import SwiftUI

struct EnvelopeCardView: View {
    let envelope: WeekEnvelope
    let skewDelta: Double
    let skewStatus: SkewStatus
    let formatter: CurrencyFormatter
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(envelope.name)
                    .font(Typography.h2())
                    .foregroundColor(ColorTheme.Text.primary)
                
                Text(formatter.string(fromCents: envelope.sumCents))
                    .font(Typography.numbers())
                    .foregroundColor(ColorTheme.Text.primary)
                
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(statusText)
                        .font(Typography.caption())
                        .foregroundColor(ColorTheme.Text.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(ColorTheme.Background.raised)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(statusColor.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch skewStatus {
        case .ok: return ColorTheme.Balance.ok
        case .medium: return ColorTheme.Balance.medium
        case .bad: return ColorTheme.Balance.bad
        }
    }
    
    private var statusText: String {
        let sign = skewDelta >= 0 ? "+" : ""
        return "Δ \(sign)\(Int(skewDelta))%"
    }
}

