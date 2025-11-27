import SwiftUI
import Charts

struct MetricsConstellationView: View {
    @ObservedObject var viewModel: MetricsConstellationViewModel
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some View {
        ZStack {
            LinearGradient.celestialBackdrop(isDark: nightModeActivated)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        orchestrator.navigateTo(.mainNexus)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(nightModeActivated))
                    }
                    
                    Spacer()
                    
                    Text("Statistics")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptiveText(nightModeActivated))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.adaptiveCard(nightModeActivated))
                
                ScrollView {
                    VStack(spacing: 20) {
                        Picker("Period", selection: $viewModel.selectedTimespan) {
                            ForEach(viewModel.timespanOptions, id: \.self) { days in
                                Text("\(days) days").tag(days)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .onChange(of: viewModel.selectedTimespan) { newValue in
                            viewModel.changeTimespan(to: newValue)
                        }
                        
                        VStack(spacing: 16) {
                            StatisticCardView(
                                title: "Average Sleep",
                                value: formatDuration(viewModel.averageSleepDuration),
                                icon: "bed.double.fill",
                                color: .nebulaBlossom
                            )
                            
                            StatisticCardView(
                                title: "Session Impact",
                                value: String(format: "%.0f%%", viewModel.correlationPercentage),
                                icon: "chart.line.uptrend.xyaxis",
                                color: .lavenderMist
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sleep Duration Trend")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            if #available(iOS 16.0, *) {
                                Chart {
                                    ForEach(Array(viewModel.metricsData.enumerated()), id: \.element.id) { index, metric in
                                        LineMark(
                                            x: .value("Date", metric.chronoMark, unit: .day),
                                            y: .value("Hours", metric.averagePhaseLength / 60)
                                        )
                                        .foregroundStyle(Color.adaptiveAccent(nightModeActivated))
                                        .interpolationMethod(.catmullRom)
                                        
                                        AreaMark(
                                            x: .value("Date", metric.chronoMark, unit: .day),
                                            y: .value("Hours", metric.averagePhaseLength / 60)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.adaptiveAccent(nightModeActivated).opacity(0.3), Color.adaptiveAccent(nightModeActivated).opacity(0.05)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .interpolationMethod(.catmullRom)
                                    }
                                }
                                .frame(height: 200)
                                .chartYAxisLabel("Hours")
                                .padding(.horizontal, 20)
                            } else {
                                SimplifiedChartView(data: viewModel.metricsData, isDark: nightModeActivated)
                                    .frame(height: 200)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color.adaptiveCard(nightModeActivated).opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    NavigationTabButton(icon: "house.fill", title: "Home", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.mainNexus)
                    }
                    
                    NavigationTabButton(icon: "moon.fill", title: "Diary", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.sleepDiary)
                    }
                    
                    NavigationTabButton(icon: "chart.bar.fill", title: "Stats", isSelected: true, isDark: nightModeActivated) {
                    }
                    
                    NavigationTabButton(icon: "gearshape.fill", title: "Settings", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.settings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.adaptiveCard(nightModeActivated).opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.adaptiveText(nightModeActivated).opacity(0.1), radius: 10, x: 0, y: -2)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func formatDuration(_ minutes: Double) -> String {
        let hours = Int(minutes / 60)
        let mins = Int(minutes.truncatingRemainder(dividingBy: 60))
        return "\(hours)h \(mins)m"
    }
}

struct StatisticCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.7))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptiveText(nightModeActivated))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.adaptiveCard(nightModeActivated))
        .cornerRadius(16)
    }
}

struct SimplifiedChartView: View {
    let data: [MetricsRecordPrism]
    let isDark: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let maxValue = data.map { $0.averagePhaseLength }.max() ?? 1
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let xStep = width / CGFloat(data.count - 1)
                    
                    for (index, metric) in data.enumerated() {
                        let x = CGFloat(index) * xStep
                        let y = height - (CGFloat(metric.averagePhaseLength / maxValue) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.adaptiveAccent(isDark), lineWidth: 2)
            }
        }
    }
}

