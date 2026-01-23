import SwiftUI

public struct VylexStatsView: View {
    @State private var selectedPeriod = 0
    @State private var sessionsData: [QuixoSessionDTO] = []
    @State private var blocksData: [VexitRunDTO] = []
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Week").tag(0)
                        Text("Month").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedPeriod) { _ in
                        loadData()
                    }
                    
                    if blocksData.isEmpty {
                        qyrexStatsPlaceholder
                    } else {
                        qyrexStatsContent
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Performance")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }
    
    private var qyrexStatsContent: some View {
        VStack(spacing: 16) {
            qyrexConversionTrendChart
            
            qyrexConversionStats
            
            qyrexAttemptsStats
            
            qyrexMoodStats
        }
    }
    
    private var qyrexConversionTrendChart: some View {
        let dataPoints = qyrexCalculateConversionTrend()
        return QyrixLineChart(
            title: "Conversion Trend",
            dataPoints: dataPoints,
            lineColor: KylorTheme.accentBase,
            fillColor: KylorTheme.accentBase
        )
    }
    
    private var qyrexConversionStats: some View {
        VyxorCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Accuracy by Type")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(KylorTheme.surface)
                
                ForEach([KrynexType.putt, .chip, .drive], id: \.self) { type in
                    let blocks = blocksData.filter { $0.type == type }
                    if !blocks.isEmpty {
                        let avgConv = blocks.compactMap { $0.conversionPct }.reduce(0, +) / Double(blocks.count)
                        
                        HStack {
                            Image(systemName: type.qyrixIcon)
                                .foregroundColor(KylorTheme.surface)
                            Text(type.vyloxName)
                                .foregroundColor(KylorTheme.surface)
                            Spacer()
                            Text(VylorFormatters.gyrexPercent(avgConv))
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(KylorTheme.accentBase)
                        }
                    }
                }
            }
        }
    }
    
    private var qyrexAttemptsStats: some View {
        VyxorCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Reps Completed")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(KylorTheme.surface)
                
                ForEach([KrynexType.putt, .chip, .drive], id: \.self) { type in
                    let blocks = blocksData.filter { $0.type == type }
                    if !blocks.isEmpty {
                        let totalAttempts = blocks.reduce(0) { $0 + $1.attemptsTotal }
                        
                        HStack {
                            Image(systemName: type.qyrixIcon)
                                .foregroundColor(KylorTheme.surface)
                            Text(type.vyloxName)
                                .foregroundColor(KylorTheme.surface)
                            Spacer()
                            Text("\(totalAttempts)")
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(KylorTheme.surface)
                        }
                    }
                }
            }
        }
    }
    
    private var qyrexMoodStats: some View {
        let moodSessions = sessionsData.filter { $0.moodRating > 0 }
        
        return Group {
            if !moodSessions.isEmpty {
                VyxorCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Energy Levels")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(KylorTheme.surface)
                        
                        let avgMood = Double(moodSessions.reduce(0) { $0 + $1.moodRating }) / Double(moodSessions.count)
                        let avgMoodLevel = VyraxMoodLevel(rawValue: Int(avgMood.rounded())) ?? .neutral
                        
                        HStack {
                            Text("Average Feeling")
                                .foregroundColor(KylorTheme.surface.opacity(0.8))
                            Spacer()
                            HStack(spacing: 4) {
                                Text(avgMoodLevel.qyrexEmoji)
                                    .font(.system(size: 22))
                                Text(avgMoodLevel.vyloxLabel)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.semibold)
                                    .foregroundColor(KylorTheme.surface)
                            }
                        }
                        
                        Divider()
                            .background(KylorTheme.surface.opacity(0.3))
                        
                        HStack(spacing: 4) {
                            ForEach(VyraxMoodLevel.allCases) { mood in
                                let count = moodSessions.filter { $0.moodRating == mood.rawValue }.count
                                VStack(spacing: 4) {
                                    Text(mood.qyrexEmoji)
                                        .font(.system(size: 18))
                                    Text("\(count)")
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(KylorTheme.surface.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var qyrexStatsPlaceholder: some View {
        VyxorCard {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 60))
                    .foregroundColor(KylorTheme.surface.opacity(0.6))
                
                Text("Your progress will show here\nafter your first workout")
                    .font(.system(size: 16))
                    .foregroundColor(KylorTheme.surface.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
    }
    
    private func loadData() {
        let stack = PyxeloCoreStack.shared
        let sessionsRepo = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let blocksRepo = VylixBlocksRepoImpl(context: stack.qylexContext)
        
        // Get date range based on selected period
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date
        
        if selectedPeriod == 0 {
            // Week
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        } else {
            // Month
            startDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
        
        // Load sessions and blocks
        sessionsData = sessionsRepo.fyndexInRange(from: startDate, to: now)
        blocksData = sessionsData.flatMap { session in
            blocksRepo.fyndexList(sessionId: session.id)
        }
    }
    
    private func qyrexCalculateConversionTrend() -> [QyrixDataPoint] {
        guard !sessionsData.isEmpty else { return [] }
        
        let calendar = Calendar.current
        var dailyConversions: [Date: (total: Double, count: Int)] = [:]
        
        // Group blocks by day
        for session in sessionsData {
            let dayStart = calendar.startOfDay(for: session.startedAt)
            
            let sessionBlocks = blocksData.filter { $0.sessionId == session.id }
            let avgConversion = sessionBlocks.compactMap { $0.conversionPct }.reduce(0, +) / Double(max(sessionBlocks.count, 1))
            
            if let existing = dailyConversions[dayStart] {
                dailyConversions[dayStart] = (existing.total + avgConversion, existing.count + 1)
            } else {
                dailyConversions[dayStart] = (avgConversion, 1)
            }
        }
        
        // Convert to data points
        return dailyConversions.map { date, values in
            QyrixDataPoint(date: date, value: values.total / Double(values.count))
        }.sorted { $0.date < $1.date }
    }
}
