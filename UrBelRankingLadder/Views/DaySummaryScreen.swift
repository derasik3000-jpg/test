import SwiftUI

struct DaySummaryScreen: View {
    @StateObject var viewModel: DaySummaryViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                
                ZStack {
                    // Тёмный фон
                    AppBackgroundView()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Header с датой
                            headerView(screenWidth: screenWidth)
                            
                            let metrics = viewModel.dayMetrics ?? DailyMetricsDTO(
                                dayIdentifier: String.todayIdentifier(),
                                morningMetric: 0,
                                noonMetric: 0,
                                eveningMetric: 0,
                                snackMetric: 0,
                                averageMetric: 0,
                                hasGoldStatus: false,
                                exportTimestamp: nil
                            )
                            
                            // Главная карточка с балансом
                            averageBalanceCard(metrics: metrics, screenWidth: screenWidth)
                            
                            // Карточки приёмов пищи
                            mealSlotsGrid(metrics: metrics, screenWidth: screenWidth)
                            
                            if let timeline = viewModel.dayTimeline {
                                sectionCard(title: "Timeline", screenWidth: screenWidth) {
                                    DayTimelineView(timelineData: timeline)
                                }
                            }
                            
                            if let weeklyBars = viewModel.weeklyBars {
                                sectionCard(title: "Weekly Overview", screenWidth: screenWidth) {
                                    WeeklyBarsChartView(barsData: weeklyBars)
                                }
                            }
                            
                            exportButton(screenWidth: screenWidth)
                                .padding(.top, 8)
                        }
                        .frame(width: screenWidth)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                    .frame(width: screenWidth)
                }
                .frame(width: screenWidth)
            }
            .navigationTitle("Day Summary")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.loadDaySummary()
        }
    }
    
    // MARK: - Header
    private func headerView(screenWidth: CGFloat) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.appTextSecondary)
                
                Text(Date(), style: .date)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.appTextPrimary)
            }
            
            Spacer()
            
            // Иконка календаря
            Circle()
                .fill(Color.appCardBackground)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appAccentOrange)
                )
        }
        .frame(width: screenWidth - 32)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Average Balance Card
    private func averageBalanceCard(metrics: DailyMetricsDTO, screenWidth: CGFloat) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Average Balance")
                        .font(.subheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(metrics.averageMetric)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.appAccentYellow, .appAccentOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("/100")
                            .font(.title2.weight(.medium))
                            .foregroundColor(.appTextTertiary)
                    }
                }
                
                Spacer()
                
                if metrics.hasGoldStatus {
                    goldBadge
                }
            }
            
            // Progress bar
            progressBar(value: Double(metrics.averageMetric) / 100.0, width: screenWidth - 72)
        }
        .padding(20)
        .frame(width: screenWidth - 32)
        .background(Color.appCardBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Gold Badge
    private var goldBadge: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.appAccentYellow, .appAccentOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            Text("Gold!")
                .font(.caption.weight(.bold))
                .foregroundColor(.appAccentYellow)
        }
    }
    
    // MARK: - Progress Bar
    private func progressBar(value: Double, width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.appBackgroundSecondary)
                .frame(width: width, height: 8)
            
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.appAccentYellow, .appAccentOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * CGFloat(min(value, 1.0)), height: 8)
        }
        .frame(width: width, height: 8)
    }
    
    // MARK: - Meal Slots Grid
    private func mealSlotsGrid(metrics: DailyMetricsDTO, screenWidth: CGFloat) -> some View {
        let cardWidth = (screenWidth - 32 - 12) / 2 // padding + spacing
        
        return LazyVGrid(columns: [
            GridItem(.fixed(cardWidth), spacing: 12),
            GridItem(.fixed(cardWidth), spacing: 12)
        ], spacing: 12) {
            mealSlotCard(
                icon: "sunrise.fill",
                label: "Morning",
                value: metrics.morningMetric,
                color: .appAccentYellow,
                width: cardWidth
            )
            mealSlotCard(
                icon: "sun.max.fill",
                label: "Noon",
                value: metrics.noonMetric,
                color: .appAccentOrange,
                width: cardWidth
            )
            mealSlotCard(
                icon: "sunset.fill",
                label: "Evening",
                value: metrics.eveningMetric,
                color: .appAccentOrange,
                width: cardWidth
            )
            mealSlotCard(
                icon: "leaf.fill",
                label: "Snack",
                value: metrics.snackMetric,
                color: .appAccentGold,
                width: cardWidth
            )
        }
        .frame(width: screenWidth - 32)
    }
    
    private func mealSlotCard(icon: String, label: String, value: Int, color: Color, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.appTextPrimary)
            }
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
        }
        .padding(16)
        .frame(width: width)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Section Card
    private func sectionCard<Content: View>(title: String, screenWidth: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            content()
        }
        .padding(20)
        .frame(width: screenWidth - 32, alignment: .leading)
        .background(Color.appCardBackground)
        .cornerRadius(20)
    }
    
    // MARK: - Export Button
    private func exportButton(screenWidth: CGFloat) -> some View {
        Button(action: {
            Task {
                await viewModel.exportDay()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Export Day Report")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.black)
            .frame(width: screenWidth - 32)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.appAccentYellow, .appAccentOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
