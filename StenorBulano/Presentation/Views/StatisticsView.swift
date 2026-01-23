import SwiftUI

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        totalSpendingSection
                        averagePerWeekSection
                        envelopePieChartSection
                        weeklyBarChartSection
                        envelopeBreakdownSection
                        weeksWithBadgesSection
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
            Text("Statistics")
                .font(Typography.h1())
                .foregroundColor(ColorTheme.Text.inverse)
            Spacer()
        }
        .padding()
    }
    
    private var totalSpendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Spending")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            Text(viewModel.totalSpending)
                .font(Typography.numbers())
                .foregroundColor(ColorTheme.Text.primary)
            
            Text("\(viewModel.totalWeeks) weeks tracked")
                .font(Typography.caption())
                .foregroundColor(ColorTheme.Text.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var averagePerWeekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average Per Week")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            Text(viewModel.averagePerWeek)
                .font(Typography.numbers())
                .foregroundColor(ColorTheme.Text.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var envelopeBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Envelopes")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            ForEach(viewModel.topEnvelopes, id: \.name) { envelope in
                HStack {
                    Text(envelope.name)
                        .font(Typography.body())
                        .foregroundColor(ColorTheme.Text.primary)
                    
                    Spacer()
                    
                    Text(envelope.total)
                        .font(Typography.body())
                        .foregroundColor(ColorTheme.Text.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var weeksWithBadgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(viewModel.weeksWithBadges)")
                        .font(Typography.numbers())
                        .foregroundColor(ColorTheme.Balance.ok)
                    Text("Balanced Weeks")
                        .font(Typography.caption())
                        .foregroundColor(ColorTheme.Text.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("\(viewModel.currentStreak)")
                        .font(Typography.numbers())
                        .foregroundColor(ColorTheme.Balance.medium)
                    Text("Current Streak")
                        .font(Typography.caption())
                        .foregroundColor(ColorTheme.Text.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var envelopePieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Distribution")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            if !viewModel.pieChartData.isEmpty {
                PieChartView(data: viewModel.pieChartData)
                    .frame(height: 200)
                
                VStack(spacing: 8) {
                    ForEach(viewModel.pieChartData, id: \.name) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 12, height: 12)
                            Text(item.name)
                                .font(Typography.caption())
                                .foregroundColor(ColorTheme.Text.primary)
                            Spacer()
                            Text(String(format: "%.1f%%", item.value))
                                .font(Typography.caption())
                                .foregroundColor(ColorTheme.Text.secondary)
                        }
                    }
                }
            } else {
                Text("No data yet")
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondary)
                    .frame(height: 100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
    
    private var weeklyBarChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 4 Weeks")
                .font(Typography.h2())
                .foregroundColor(ColorTheme.Text.primary)
            
            if !viewModel.barChartData.isEmpty {
                BarChartView(data: viewModel.barChartData)
                    .frame(height: 200)
            } else {
                Text("No data yet")
                    .font(Typography.body())
                    .foregroundColor(ColorTheme.Text.secondary)
                    .frame(height: 100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(ColorTheme.Background.raised)
        .cornerRadius(16)
    }
}

