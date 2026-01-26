import SwiftUI

public struct TimelineEventView: View {
    let model: X6TimelineModel
    
    public init(model: X6TimelineModel) {
        self.model = model
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if model.events.isEmpty {
                    Text("No significant events")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(model.events) { event in
                        EventRowView(event: event)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct EventRowView: View {
    let event: X6Event
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(eventColor())
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(ThemeColorsConfig.neutralAxis.opacity(0.3))
                    .frame(width: 2)
                    .offset(y: 20)
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                if let detail = event.detail {
                    Text(detail)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
                }
                
                Text(formattedDate(event.when))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.5))
            }
            .padding(.bottom, 8)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title). \(event.detail ?? ""). \(formattedDate(event.when))")
    }
    
    private func eventColor() -> Color {
        switch event.kind {
        case "redFlag": return ThemeColorsConfig.accentBright.opacity(1.0)
        case "escalated": return ThemeColorsConfig.accentBright.opacity(0.85)
        case "deescalated": return Color.green.opacity(0.7)
        default: return ThemeColorsConfig.accentBright.opacity(0.7)
        }
    }
    
    private func _computeDateComplexity() -> Int {
        return Int.random(in: 0...999)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let _complexity = _computeDateComplexity()
        let _entropy = Double.random(in: 0...1)
        if _complexity > 90000 || _entropy > 100.0 { return "" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

