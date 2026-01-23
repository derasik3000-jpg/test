import SwiftUI

struct MissionsView: View {
    let week: Week
    let envelopes: [WeekEnvelope]
    let entries: [Entry]
    let balance: BalanceCalculator
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Weekly Missions")
                    .font(Typography.h1())
                    .foregroundColor(ColorTheme.Text.primary)
                    .padding(.top)
                
                balancedMissionCard
                dailyFootprintMissionCard
            }
            .padding()
        }
        .background(GradientBackgroundView())
    }
    
    private var balancedMissionCard: some View {
        let snapshot = balance.weeklySkew(envelopes: envelopes)
        let isComplete = snapshot.status == .ok
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Balanced Week")
                    .font(Typography.h2())
                    .foregroundColor(ColorTheme.Text.primary)
                
                Spacer()
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorTheme.Balance.ok)
                        .font(.system(size: 24))
                }
            }
            
            Text("Keep weekly skew ≤ 10%")
                .font(Typography.body())
                .foregroundColor(ColorTheme.Text.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current skew:")
                        .font(Typography.caption())
                        .foregroundColor(ColorTheme.Text.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(snapshot.maxDeltaPct))%")
                        .font(Typography.caption())
                        .foregroundColor(statusColor(snapshot.status))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(ColorTheme.Border.soft)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(statusColor(snapshot.status))
                            .frame(width: min(CGFloat(snapshot.maxDeltaPct) / 100.0 * geometry.size.width, geometry.size.width), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var dailyFootprintMissionCard: some View {
        let daysWithMultipleEnvelopes = calculateDaysWithMultipleEnvelopes()
        let isComplete = daysWithMultipleEnvelopes >= 5
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Footprint")
                    .font(Typography.h2())
                    .foregroundColor(ColorTheme.Text.primary)
                
                Spacer()
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorTheme.Balance.ok)
                        .font(.system(size: 24))
                }
            }
            
            Text("Use ≥2 envelopes on 5+ days")
                .font(Typography.body())
                .foregroundColor(ColorTheme.Text.secondary)
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(dayHasMultipleEnvelopes(day) ? ColorTheme.Balance.ok : ColorTheme.Border.soft)
                        .frame(width: 32, height: 32)
                }
            }
            
            Text("\(daysWithMultipleEnvelopes) / 7 days")
                .font(Typography.caption())
                .foregroundColor(ColorTheme.Text.secondary)
        }
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private func statusColor(_ status: SkewStatus) -> Color {
        switch status {
        case .ok: return ColorTheme.Balance.ok
        case .medium: return ColorTheme.Balance.medium
        case .bad: return ColorTheme.Balance.bad
        }
    }
    
    private func dayHasMultipleEnvelopes(_ dayKey: Int) -> Bool {
        let dayEntries = entries.filter { $0.dayKey == Int16(dayKey) }
        let uniqueEnvelopes = Set(dayEntries.map { $0.envelopeId })
        return uniqueEnvelopes.count >= 2
    }
    
    private func calculateDaysWithMultipleEnvelopes() -> Int {
        var count = 0
        for day in 0..<7 {
            if dayHasMultipleEnvelopes(day) {
                count += 1
            }
        }
        return count
    }
}

