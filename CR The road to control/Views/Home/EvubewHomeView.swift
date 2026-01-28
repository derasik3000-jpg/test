import SwiftUI

struct EvubewHomeView: View {
    @EnvironmentObject private var cuqavuViewModel: DegubaHomeViewModel
    @State private var axemobSelectedSession: AxemobSessionModel?
    @State private var ehonohShowSettings = false
    @ObservedObject var degubaThemeManager = CuqavuThemeManager.shared
    @State private var cuqavuRefreshTrigger = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок и кнопки (настройки и новая сессия)
                        HStack {
                            Text("Home")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Кнопка "+" для новой сессии
                                Button(action: {
                                    cuqavuViewModel.ehonohShowNewSession = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            LinearGradient(
                                                colors: [degubaThemeManager.degubaCurrentTheme.evubewPrimary, degubaThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(color: degubaThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4), radius: 8, x: 0, y: 3)
                                }
                                
                                // Кнопка настроек
                                Button(action: {
                                    ehonohShowSettings = true
                                }) {
                                    Image(systemName: "gear")
                                        .font(.system(size: 20))
                                        .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                                        .padding(12)
                                        .background(degubaThemeManager.degubaCurrentTheme.degubaCardBackground)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        DegubaFocusSessionCard(totalMinutes: cuqavuViewModel.axemobGetTotalMinutesToday(), refreshTrigger: cuqavuRefreshTrigger, themeManager: degubaThemeManager)
                            .padding(.horizontal)
                        
                        if !cuqavuViewModel.evubewTodaySessions.isEmpty {
                            ImprovedEnergyChartView(
                                dataPoints: cuqavuViewModel.ehonohGetEnergyDataPoints(),
                                timeLabels: cuqavuViewModel.degubaGetTimeLabels(),
                                sessions: cuqavuViewModel.evubewTodaySessions
                            )
                            .padding(.horizontal)
                        }
                        
                        if let summary = cuqavuViewModel.cuqavuDailySummary {
                            CuqavuDailySummaryCard(summary: summary)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Sessions")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                                .padding(.horizontal)
                            
                            if cuqavuViewModel.evubewTodaySessions.isEmpty {
                                AxemobEmptyStateView()
                                    .padding()
                            } else {
                                ForEach(cuqavuViewModel.evubewTodaySessions.prefix(5)) { session in
                                    Button(action: {
                                        axemobSelectedSession = session
                                    }) {
                                        EhonohSessionRowView(session: session, refreshTrigger: cuqavuRefreshTrigger)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $axemobSelectedSession) { session in
                DegubaSessionDetailView(session: session)
            }
            .sheet(isPresented: $ehonohShowSettings) {
                EhonohSettingsView()
            }
            .sheet(isPresented: $cuqavuViewModel.ehonohShowNewSession) {
                CuqavuNewSessionView(defaultMood: cuqavuViewModel.cuqavuGetCurrentMood())
            }
            .onAppear {
                cuqavuViewModel.cuqavuLoadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TimeUnitsChanged"))) { _ in
                cuqavuRefreshTrigger = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SessionsUpdated"))) { _ in
                cuqavuViewModel.cuqavuLoadData()
                cuqavuRefreshTrigger = UUID()
            }
        }
    }
}

struct DegubaFocusSessionCard: View {
    let totalMinutes: Int
    let refreshTrigger: UUID
    let themeManager: CuqavuThemeManager
    @State private var evubewAnimationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
                
                Text("Focus Session")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Text(AxemobTimeFormatter.shared.cuqavuFormatMinutesInt(totalMinutes))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
                    .id(refreshTrigger)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [themeManager.degubaCurrentTheme.evubewPrimary, themeManager.degubaCurrentTheme.cuqavuSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(evubewAnimationProgress, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(24)
        .background(themeManager.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2)) {
                evubewAnimationProgress = CGFloat(totalMinutes) / 480.0
            }
        }
    }
}

struct CuqavuDailySummaryCard: View {
    let summary: CuqavuDailySummaryModel
    @State private var degubaShowChart = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 24))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Daily Summary")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
            }
            
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("\(String(format: "%.1f", summary.avgEnergy))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    Text("Avg Energy")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("\(String(format: "%.1f", summary.avgMood))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary)
                    
                    Text("Avg Mood")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("\(summary.degubaTotalMinutes)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    Text("Total Min")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
            }
        }
        .padding(24)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
}

struct AxemobEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No sessions yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            Text("Tap the + button to add your first session")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Improved Energy Chart
struct ImprovedEnergyChartView: View {
    let dataPoints: [Double]
    let timeLabels: [String]
    let sessions: [AxemobSessionModel]
    @ObservedObject var themeManager = CuqavuThemeManager.shared
    @State private var animationProgress: CGFloat = 0
    
    private var maxEnergy: Double {
        dataPoints.max() ?? 10
    }
    
    private var minEnergy: Double {
        dataPoints.min() ?? 0
    }
    
    private var avgEnergy: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.reduce(0, +) / Double(dataPoints.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с иконкой
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
                
                Text("Today's Energy")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Статистика
            HStack(spacing: 20) {
                StatItem(
                    label: "Max",
                    value: String(format: "%.1f", maxEnergy),
                    color: themeManager.degubaCurrentTheme.evubewPrimary
                )
                
                Divider()
                    .frame(height: 30)
                    .background(themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                StatItem(
                    label: "Avg",
                    value: String(format: "%.1f", avgEnergy),
                    color: themeManager.degubaCurrentTheme.cuqavuSecondary
                )
                
                Divider()
                    .frame(height: 30)
                    .background(themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                StatItem(
                    label: "Min",
                    value: String(format: "%.1f", minEnergy),
                    color: themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.7)
                )
            }
            .padding(.horizontal, 20)
            
            // График с улучшенной визуализацией
            VStack(spacing: 8) {
                // Y-axis labels и график
                HStack(alignment: .bottom, spacing: 12) {
                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach([10, 7, 5, 3, 0], id: \.self) { value in
                            Text("\(value)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.6))
                                .frame(height: 40)
                        }
                    }
                    .frame(width: 25)
                    
                    // График
                    ZStack(alignment: .bottomLeading) {
                        // Сетка
                        GridView(maxValue: 10, themeManager: themeManager)
                        
                        // График
                        EvubewLineChart(
                            cuqavuDataPoints: dataPoints,
                            axemobLabels: timeLabels,
                            ehonohMaxValue: 10
                        )
                        .frame(height: 200)
                    }
                }
                
                // X-axis labels (время)
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 25)
                    
                    HStack {
                        ForEach(Array(timeLabels.enumerated()), id: \.offset) { index, label in
                            if index == 0 || index == timeLabels.count - 1 || index % max(1, timeLabels.count / 4) == 0 {
                                Text(label)
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                            } else {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 16)
        }
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            themeManager.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
        }
    }
}

struct GridView: View {
    let maxValue: Double
    let themeManager: CuqavuThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let stepY = height / CGFloat(maxValue)
            
            // Горизонтальные линии сетки
            ForEach([0, 2, 5, 7, 10], id: \.self) { value in
                Path { path in
                    let y = height - (CGFloat(value) * stepY)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(
                    themeManager.degubaCurrentTheme.evubewPrimary.opacity(0.15),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
            }
        }
    }
}

struct EhonohSessionRowView: View {
    let session: AxemobSessionModel
    let refreshTrigger: UUID
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: session.type.evubewIcon)
                .font(.system(size: 24))
                .foregroundColor(session.type.cuqavuColor)
                .frame(width: 48, height: 48)
                .background(session.type.cuqavuColor.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                HStack(spacing: 12) {
                    Label(AxemobTimeFormatter.shared.evubewFormatMinutes(session.durationMin), systemImage: "clock")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .id(refreshTrigger)
                    
                    Label("Energy: \(session.energyLevel)", systemImage: "bolt.fill")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
    }
}

