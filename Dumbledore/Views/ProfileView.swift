// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTimeRange = 0
    @State private var showingSettings = false
    
    private let timeRanges = ["7 days", "30 days", "90 days"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .iWingPadding) {
                    // Header Stats
                    VStack(spacing: .iWingPadding) {
                        Text("Your Progress")
                            .font(.iWingTitle)
                            .foregroundColor(.iWingTextPrimary)
                        
                        // Time Range Selector
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(0..<timeRanges.count, id: \.self) { index in
                                Text(timeRanges[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: .infinity)
                        .onChange(of: selectedTimeRange) { newValue in
                            Task {
                                await viewModel.loadData(for: newValue)
                            }
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                    
                    // Useful Time Donut
                    UsefulTimeDonutView(donut: viewModel.usefulDonut)
                        .iWingCard()
                        .padding(.horizontal, .iWingPadding)
                    
                    // Topic Distribution Pie Chart
                    if !viewModel.topicPie.slices.isEmpty {
                        TopicPieChartView(pie: viewModel.topicPie)
                            .iWingCard()
                            .padding(.horizontal, .iWingPadding)
                    }
                    
                    // Daily Progress Bar Chart
                    if !viewModel.barSeries.bars.isEmpty {
                        DailyProgressBarChartView(barSeries: viewModel.barSeries)
                            .iWingCard()
                            .padding(.horizontal, .iWingPadding)
                    }
                    
                    // Weak Spots Heatmap
                    if !viewModel.weakHeatmap.cells.isEmpty {
                        WeakSpotsHeatmapView(heatmap: viewModel.weakHeatmap)
                            .iWingCard()
                            .padding(.horizontal, .iWingPadding)
                    }
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                        Text("Settings")
                            .font(.iWingHeadline)
                            .foregroundColor(.iWingTextPrimary)
                            .padding(.horizontal, .iWingPadding)
                        
                        VStack(spacing: 0) {
                            SettingsRowView(title: "Language Level", value: "B1") {
                                HapticEngine.play(.light)
                                showingSettings = true
                            }
                            Divider()
                            SettingsRowView(title: "Voice Speed", value: "1.0x") {
                                HapticEngine.play(.light)
                                showingSettings = true
                            }
                            Divider()
                            SettingsRowView(title: "Auto Hints", value: "On") {
                                HapticEngine.play(.light)
                                showingSettings = true
                            }
                            Divider()
                            SettingsRowView(title: "Notifications", value: "Enabled") {
                                HapticEngine.play(.light)
                                showingSettings = true
                            }
                        }
                        .iWingCard()
                        .padding(.horizontal, .iWingPadding)
                    }
                }
                .padding(.vertical, .iWingPadding)
            }
            .fillGradientBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Settings") { showingSettings = true }
                        NavigationLink("Diagnostics") { DiagnosticsView() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadData(for: selectedTimeRange)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct TopicPieChartView: View {
    let pie: TopicPieModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .iWingPadding) {
            Text("Practice by Topic")
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
            
            HStack {
                // Pie Chart
                ZStack {
                    ForEach(Array(pie.slices.enumerated()), id: \.offset) { index, slice in
                        PieSliceView(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            color: colorForSlice(index)
                        )
                    }
                }
                .frame(width: 120, height: 120)
                
                // Legend
                VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                    ForEach(Array(pie.slices.enumerated()), id: \.offset) { index, slice in
                        HStack {
                            Circle()
                                .fill(colorForSlice(index))
                                .frame(width: 12, height: 12)
                            
                            Text(slice.topicTag)
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextPrimary)
                            
                            Spacer()
                            
                            Text("\(slice.minutes)m")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                        }
                    }
                }
                .padding(.leading, .iWingPadding)
            }
        }
        .padding()
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousSlices = pie.slices.prefix(index).reduce(0) { $0 + $1.share }
        return Angle(degrees: previousSlices * 360)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentSlices = pie.slices.prefix(index + 1).reduce(0) { $0 + $1.share }
        return Angle(degrees: currentSlices * 360)
    }
    
    private func colorForSlice(_ index: Int) -> Color {
        let colors: [Color] = [
            .iWingAccent,
            .iWingAccent.opacity(0.85),
            .iWingAccent.opacity(0.70),
            .iWingAccent.opacity(0.55)
        ]
        return colors[index % colors.count]
    }
}

struct PieSliceView: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 60, y: 60)
            let radius: CGFloat = 50
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
    }
}

struct DailyProgressBarChartView: View {
    let barSeries: BarSeries
    
    var body: some View {
        VStack(alignment: .leading, spacing: .iWingPadding) {
            Text("Daily Progress")
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
            
            GeometryReader { geometry in
                let barWidth = min(30, (geometry.size.width - CGFloat(barSeries.bars.count + 1) * 4) / CGFloat(barSeries.bars.count))
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(barSeries.bars) { bar in
                        VStack(spacing: 4) {
                            Spacer(minLength: 0)
                            
                            Rectangle()
                                .fill(bar.reachedGoal ? Color.iWingAccent : Color.iWingAccent.opacity(0.7))
                                .frame(width: barWidth, height: max(4, CGFloat(bar.minutes) * 2))
                                .cornerRadius(2)
                            
                            Text(dayLabel(for: bar.dayKey))
                                .font(.system(size: 9))
                                .foregroundColor(.iWingTextMuted)
                                .lineLimit(1)
                                .frame(width: barWidth + 10, height: 16)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
                .frame(maxWidth: geometry.size.width, alignment: .center)
            }
            .frame(height: 120)
        }
        .padding()
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct WeakSpotsHeatmapView: View {
    let heatmap: WeakHeatmapModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .iWingPadding) {
            Text("Weak Spots")
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
            
            VStack(spacing: 4) {
                ForEach(0..<7) { week in
                    HStack(spacing: 4) {
                        ForEach(0..<7) { day in
                            let cell = heatmap.cells.first { 
                                Calendar.current.component(.weekday, from: $0.dayKey) == day + 1 &&
                                Calendar.current.component(.weekOfYear, from: $0.dayKey) == week + 1
                            }
                            
                            Rectangle()
                                .fill(colorForIntensity(cell?.intensity ?? 0))
                                .frame(width: 20, height: 20)
                                .cornerRadius(2)
                        }
                    }
                }
            }
            
            HStack {
                Text("Less")
                    .font(.iWingSmall)
                    .foregroundColor(.iWingTextMuted)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.iWingWarning.opacity(0.2 + Double(0.2 * Double(5 - 1))))
                            .frame(width: 12, height: 12)
                            .cornerRadius(1)
                    }
                }
                
                Text("More")
                    .font(.iWingSmall)
                    .foregroundColor(.iWingTextMuted)
            }
        }
        .padding()
    }
    
    private func colorForIntensity(_ intensity: Double) -> Color {
        Color.iWingWarning.opacity(0.1 + intensity * 0.9)
    }
}

struct SettingsRowView: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextPrimary)
                
                Spacer()
                
                Text(value)
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextMuted)
                
                Image(systemName: "chevron.right")
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextMuted)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var level = 2
    @State private var ttsRate = 1.0
    @State private var autoHints = true
    @State private var notifications = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.iWingSurface.ignoresSafeArea()
                
                Form {
                    Section("Language Level") {
                        Picker("Level", selection: $level) {
                            Text("A2").tag(1)
                            Text("B1").tag(2)
                            Text("B2").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section("Voice Settings") {
                        VStack(alignment: .leading) {
                            Text("Speech Rate")
                            Slider(value: $ttsRate, in: 0.5...1.5, step: 0.1)
                            Text("\(ttsRate, specifier: "%.1f")x")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                        }
                    }
                    
                    Section("Learning") {
                        Toggle("Auto Hints", isOn: $autoHints)
                        Toggle("Notifications", isOn: $notifications)
                    }
                    
                    Section("Privacy") {
                        Toggle("Store Transcripts", isOn: .constant(true))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticEngine.play(.light)
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

// DiagnosticsView.swift (inline)
struct DiagnosticsView: View {
    @State private var logLines: [String] = []
    private let container = DIContainer.shared
    @State private var spoke = false
    
    var body: some View {
        List {
            Section("Repositories") {
                Button("Test ScenarioRepository.listAll") { run { try await testListScenarios() } }
                Button("Test ImmersionRepository.feed") { run { try await testFeed() } }
                Button("Test MicroLessonRepository.queueForToday") { run { try await testQueue() } }
                Button("Test ProgressRepository.usefulDonut") { run { try await testDonut() } }
            }
            Section("UseCases") {
                Button("BuildUsefulDonutUseCase") { run { try await testUC_Donut() } }
                Button("BuildTopicPieUseCase") { run { try await testUC_Pie() } }
                Button("BuildBarSeriesUseCase") { run { try await testUC_Bar() } }
                Button("BuildWeakHeatmapUseCase") { run { try await testUC_Heat() } }
            }
            Section("Adapters") {
                Button("Speak sample TTS") { run { await testTTS() } }
                Button("Request notifications auth") { run { try await testNotifications() } }
            }
            Section("Log") {
                ForEach(Array(logLines.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.iWingSmall)
                }
            }
        }
        .navigationTitle("Diagnostics")
    }
    
    private func run(_ block: @escaping () async throws -> Void) {
        HapticEngine.play(.light)
        Task {
            do { 
                try await block()
                append("OK")
                HapticEngine.play(.success)
            } catch { 
                append("ERR: \(error)")
                HapticEngine.play(.warning)
            }
        }
    }
    
    private func append(_ line: String) { logLines.append("[\(Date())] \(line)") }
    
    // MARK: - Repo Tests
    private func testListScenarios() async throws {
        let res = try await container.scenarioRepository.listAll(minLevel: nil)
        append("scenarios=\(res.count)")
    }
    private func testFeed() async throws {
        let res = try await container.immersionRepository.feed(byTopics: [], limit: 5)
        append("feed=\(res.count)")
    }
    private func testQueue() async throws {
        let res = try await container.microLessonRepository.queueForToday()
        append("queue=\(res.count)")
    }
    private func testDonut() async throws {
        let res = try await container.progressRepository.usefulDonut(dayKey: Date().dayKey)
        append("donut=\(res.usefulMinutes)/\(res.dailyGoalMinutes)")
    }
    
    // MARK: - Use Case Tests
    private func testUC_Donut() async throws {
        let res = try await container.buildUsefulDonutUseCase.execute(dayKey: Date().dayKey)
        append("uc_donut.progress=\(String(format: "%.2f", res.progress))")
    }
    private func testUC_Pie() async throws {
        let range = Date().addingTimeInterval(-7*86400)...Date()
        let res = try await container.buildTopicPieUseCase.execute(range: range)
        append("uc_pie.total=\(res.totalMinutes), slices=\(res.slices.count)")
    }
    private func testUC_Bar() async throws {
        let range = Date().addingTimeInterval(-7*86400)...Date()
        let res = try await container.buildBarSeriesUseCase.execute(range: range)
        append("uc_bar.bars=\(res.bars.count)")
    }
    private func testUC_Heat() async throws {
        let range = Date().addingTimeInterval(-14*86400)...Date()
        let res = try await container.buildWeakHeatmapUseCase.execute(range: range)
        append("uc_heat.cells=\(res.cells.count)")
    }
    
    // MARK: - Adapters Tests
    private func testTTS() async {
        await container.ttsAdapter.speak("This is a sample text to speech test.", rate: 1.0)
        append("tts_spoken=true")
    }
    private func testNotifications() async throws {
        try await container.notificationAdapter.requestAuthIfNeeded()
        await container.notificationAdapter.presentMicroLessonPrompt(title: "3 minutes free?", body: "Repeat 4 words now")
        append("notifications_ok")
    }
}

// MARK: - ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var usefulDonut = UsefulDonutModel(dayKey: Date(), usefulMinutes: 0, dailyGoalMinutes: 20)
    @Published var topicPie = TopicPieModel(range: Date()...Date(), totalMinutes: 0, slices: [])
    @Published var barSeries = BarSeries(bars: [])
    @Published var weakHeatmap = WeakHeatmapModel(cells: [])
    
    private let donutUseCase: BuildUsefulDonutUseCase
    private let topicPieUseCase: BuildTopicPieUseCase
    private let barSeriesUseCase: BuildBarSeriesUseCase
    private let weakHeatmapUseCase: BuildWeakHeatmapUseCase
    
    init() {
        let container = DIContainer.shared
        self.donutUseCase = container.buildUsefulDonutUseCase
        self.topicPieUseCase = container.buildTopicPieUseCase
        self.barSeriesUseCase = container.buildBarSeriesUseCase
        self.weakHeatmapUseCase = container.buildWeakHeatmapUseCase
    }
    
    func loadData(for timeRange: Int) async {
        do {
            let days = timeRange == 0 ? 7 : timeRange == 1 ? 30 : 90
            let range = Date().addingTimeInterval(-Double(days * 24 * 3600))...Date()
            
            usefulDonut = try await donutUseCase.execute(dayKey: Date().dayKey)
            topicPie = try await topicPieUseCase.execute(range: range)
            
            // Always get 7 bars for visualization, but fetch data for the selected range
            let fullBarSeries = try await barSeriesUseCase.execute(range: range)
            
            // For 30 and 90 days, aggregate into 7 weekly bars
            if timeRange == 0 {
                // 7 days - use as is (daily bars)
                barSeries = fullBarSeries
            } else {
                // 30 or 90 days - aggregate into 7 weekly bars
                let weeksToShow = 7
                let daysPerBar = days / weeksToShow
                
                var weeklyBars: [DayBar] = []
                for week in 0..<weeksToShow {
                    let startDay = week * daysPerBar
                    let endDay = min(startDay + daysPerBar, fullBarSeries.bars.count)
                    
                    let weekBars = Array(fullBarSeries.bars[max(0, min(startDay, fullBarSeries.bars.count))..<min(endDay, fullBarSeries.bars.count)])
                    let totalMinutes = weekBars.reduce(0) { $0 + $1.minutes }
                    
                    // Use a date representing the week
                    let weekDate = Date().addingTimeInterval(-Double((weeksToShow - week - 1) * daysPerBar * 24 * 3600))
                    weeklyBars.append(DayBar(dayKey: weekDate, minutes: totalMinutes, reachedGoal: totalMinutes >= 20))
                }
                
                barSeries = BarSeries(bars: weeklyBars)
            }
            
            weakHeatmap = try await weakHeatmapUseCase.execute(range: range)
        } catch {
            print("Error loading profile data: \(error)")
        }
    }
}

#Preview {
    ProfileView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
