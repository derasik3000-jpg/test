import SwiftUI

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.weeks) { week in
                            WeekRowView(
                                week: week,
                                envelopes: viewModel.envelopes(for: week.id),
                                badges: viewModel.badges(for: week.id)
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    private var header: some View {
        HStack {
            Text("Archive")
                .font(Typography.h1())
                .foregroundColor(ColorTheme.Text.inverse)
            Spacer()
        }
        .padding()
    }
}

struct WeekRowView: View {
    let week: Week
    let envelopes: [WeekEnvelope]
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Week \(week.isoWeek)")
                    .font(Typography.h2())
                    .foregroundColor(ColorTheme.Text.primary)
                
                Spacer()
                
                if !badges.isEmpty {
                    Image(systemName: "medal.fill")
                        .foregroundColor(ColorTheme.Balance.ok)
                }
            }
            
            Text(AppDependencies.shared.currencyFormatter.string(fromCents: week.sumCents))
                .font(Typography.numbers())
                .foregroundColor(ColorTheme.Text.primary)
            
            HStack {
                Text("Max skew: \(week.maxDeltaPct)%")
                    .font(Typography.caption())
                    .foregroundColor(ColorTheme.Text.secondary)
                
                Spacer()
                
                Text(weekStatus)
                    .font(Typography.caption())
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var weekStatus: String {
        if week.maxDeltaPct <= 10 {
            return "Balanced"
        } else if week.maxDeltaPct <= 20 {
            return "Moderate"
        } else {
            return "High Skew"
        }
    }
    
    private var statusColor: Color {
        if week.maxDeltaPct <= 10 {
            return ColorTheme.Balance.ok
        } else if week.maxDeltaPct <= 20 {
            return ColorTheme.Balance.medium
        } else {
            return ColorTheme.Balance.bad
        }
    }
}

