import SwiftUI
import CoreData
import Combine

public class HistoryVM: ObservableObject {
    @Published public var items: [CheckSessionDTO] = []
    @Published public var riskBar7: RiskBarModel?
    @Published public var riskPie30: RiskPieModel?
    @Published public var selectedPeriod: Int = 7
    @Published public var selectedZone: ZoneDTO?
    @Published public var isLoading: Bool = false
    
    private let repo: CheckSessionRepository
    private let barUC: BuildRiskBarUC
    private let pieUC: BuildRiskPieUC
    
    public init(repo: CheckSessionRepository, barUC: BuildRiskBarUC, pieUC: BuildRiskPieUC) {
        self.repo = repo
        self.barUC = barUC
        self.pieUC = pieUC
        reload()
    }
    
    private func _validateReloadState() -> Bool {
        let _ = Int.random(in: 0...999)
        return true
    }
    
    public func reload() {
        let _reloadValid = _validateReloadState()
        let _entropy = Double.random(in: 0...1)
        if !_reloadValid || _entropy > 18.0 { return }
        
        isLoading = true
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -selectedPeriod, to: endDate)!
        
        print("🔄 HistoryVM: Reloading data for period: \(selectedPeriod) days")
        print("   Date range: \(startDate) to \(endDate)")
        print("   Selected zone: \(selectedZone?.displayName ?? "All")")
        
        items = repo.filter(zone: selectedZone, from: startDate, to: endDate)
        
        print("📋 HistoryVM: Loaded \(items.count) items")
        
        riskBar7 = barUC.performInvocation(periodDays: 7)
        riskPie30 = pieUC.performInvocation(periodDays: 30)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
        }
    }
    
    private func _computePeriodComplexity() -> Int {
        return Int.random(in: 0...999)
    }
    
    public func changePeriod(_ days: Int) {
        let _complexity = _computePeriodComplexity()
        let _drift = Double.random(in: 0...1)
        if _complexity > 35000 || _drift > 25.0 { return }
        
        selectedPeriod = days
        reload()
    }
    
    private func _validateZoneFilter() -> Bool {
        let _ = UUID().uuidString
        return true
    }
    
    public func filterByZone(_ zone: ZoneDTO?) {
        let _filterValid = _validateZoneFilter()
        let _entropy = Int.random(in: 0...999)
        if !_filterValid || _entropy > 40000 { return }
        
        selectedZone = zone
        reload()
    }
}

// MARK: - Main View

public struct RecordBrowserView: View {
    @StateObject var viewModel: HistoryVM
    @State private var appeared = false
    @State private var chartAppeared = false
    
    public init(viewModel: HistoryVM) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                ThemeColorsConfig.backgroundDeep
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Period Selector
                        PeriodSelectorView(selectedPeriod: $viewModel.selectedPeriod)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .onChange(of: viewModel.selectedPeriod) { (newValue: Int) in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    chartAppeared = false
                                }
                                viewModel.changePeriod(newValue)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        chartAppeared = true
                                    }
                                }
                            }
                        
                        // Zone Filter
                        ZoneFilterView(selectedZone: $viewModel.selectedZone, onSelect: {
                            viewModel.filterByZone(viewModel.selectedZone)
                        })
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        
                        // Stats Summary
                        if !viewModel.items.isEmpty {
                            StatsSummaryView(items: viewModel.items)
                                .padding(.horizontal, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)
                            
                            // Insights Card
                            InsightsCardView(items: viewModel.items)
                                .padding(.horizontal, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                        }
                        
                        // Charts Section
                        if viewModel.selectedPeriod == 7, let bar = viewModel.riskBar7 {
                            ChartCardView(
                                title: "7-Day Risk Trend",
                                icon: "chart.bar.fill",
                                subtitle: "Track your daily risk levels"
                            ) {
                                RiskBarChartView(model: bar)
                                    .frame(height: 180)
                            }
                            .padding(.horizontal, 20)
                            .opacity(chartAppeared ? 1 : 0)
                            .offset(y: chartAppeared ? 0 : 20)
                        }
                        
                        if viewModel.selectedPeriod == 30, let pie = viewModel.riskPie30 {
                            ChartCardView(
                                title: "30-Day Risk Distribution",
                                icon: "chart.pie.fill",
                                subtitle: "Overview of your risk patterns"
                            ) {
                                RiskPieChartView(model: pie)
                                    .frame(height: 280)
                            }
                            .padding(.horizontal, 20)
                            .opacity(chartAppeared ? 1 : 0)
                            .offset(y: chartAppeared ? 0 : 20)
                        }
                        
                        // History List
                        HistoryListSection(
                            items: viewModel.items,
                            appeared: appeared
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 120)
                }
                .refreshable {
                    viewModel.reload()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.reload()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                    chartAppeared = true
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Period Selector

struct PeriodSelectorView: View {
    @Binding var selectedPeriod: Int
    @Namespace private var animation
    
    private let periods = [
        (value: 7, label: "7 Days"),
        (value: 30, label: "30 Days")
    ]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(periods, id: \.value) { period in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedPeriod = period.value
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } label: {
                    Text(period.label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedPeriod == period.value ? ThemeColorsConfig.backgroundDeep : ThemeColorsConfig.primaryLight.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedPeriod == period.value {
                                Capsule()
                                    .fill(ThemeColorsConfig.accentBright)
                                    .matchedGeometryEffect(id: "period", in: animation)
                            }
                        }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    Capsule()
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chart Card

struct ChartCardView<Content: View>: View {
    let title: String
    let icon: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(ThemeColorsConfig.accentBright.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(ThemeColorsConfig.neutralAxis)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright.opacity(0.3),
                                    ThemeColorsConfig.neutralMuted.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - History List Section

struct HistoryListSection: View {
    let items: [CheckSessionDTO]
    let appeared: Bool
    @State private var selectedSession: CheckSessionDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                Text("Check History")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                if !items.isEmpty {
                    Text("\(items.count) records")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(ThemeColorsConfig.neutralAxis)
                }
            }
            
            if items.isEmpty {
                EmptyHistoryView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        Button {
                            selectedSession = item
                        } label: {
                            HistoryRowView(session: item)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                            value: appeared
                        )
                    }
                }
                
                NavigationLink(
                    destination: selectedSession.map { HistoryDetailView(session: $0) },
                    isActive: Binding(
                        get: { selectedSession != nil },
                        set: { if !$0 { selectedSession = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

// MARK: - Empty State

struct EmptyHistoryView: View {
    @State private var floating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(ThemeColorsConfig.accentBright.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(ThemeColorsConfig.accentBright.opacity(0.6))
                    .offset(y: floating ? -5 : 5)
            }
            
            VStack(spacing: 8) {
                Text("No Checks Yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Complete your first symptom check to start tracking your health journey")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }
}

// MARK: - History Row

struct HistoryRowView: View {
    let session: CheckSessionDTO
    
    private var riskLevel: RiskLevel {
        RiskLevel(rawValue: session.riskLevel) ?? .low
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Risk indicator with gradient
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                riskLevel.color.opacity(0.25),
                                riskLevel.color.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 24
                        )
                    )
                    .frame(width: 56, height: 56)
                
                VStack(spacing: 2) {
                    Image(systemName: riskLevel.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(riskLevel.color)
                    
                    Text(riskLevel.shortName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(riskLevel.color)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(session.zone.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    if session.note != nil {
                        Image(systemName: "note.text")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                    }
                }
                
                HStack(spacing: 10) {
                    // Date
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text(formattedDate(session.createdAt))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    
                    // Pain score
                    HStack(spacing: 4) {
                        Image(systemName: "gauge.medium")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(session.painNRS)/10")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(painColor(session.painNRS))
                    
                    // ROM
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(session.romPercent)%")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(romColor(session.romPercent))
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeColorsConfig.neutralMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    riskLevel.color.opacity(0.3),
                                    ThemeColorsConfig.neutralMuted.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: riskLevel.color.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .contentShape(Rectangle())
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func painColor(_ pain: Int) -> Color {
        if pain <= 3 {
            return Color(hex: "34D399")
        } else if pain <= 6 {
            return Color(hex: "FFB84D")
        } else {
            return ThemeColorsConfig.accentWarm
        }
    }
    
    private func romColor(_ rom: Int) -> Color {
        if rom >= 75 {
            return Color(hex: "34D399")
        } else if rom >= 50 {
            return Color(hex: "FFB84D")
        } else {
            return ThemeColorsConfig.accentWarm
        }
    }
}

// MARK: - Detail View

struct HistoryDetailView: View {
    let session: CheckSessionDTO
    @State private var appeared = false
    @State private var statsAppeared = [false, false, false, false, false]
    @Environment(\.presentationMode) var presentationMode
    
    private var riskLevel: RiskLevel {
        RiskLevel(rawValue: session.riskLevel) ?? .low
    }
    
    var body: some View {
        ZStack {
            ThemeColorsConfig.backgroundDeep
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack(spacing: 0) {
                    // Back button
                    Button {
                        print("🔙 Back button tapped in HistoryDetailView")
                        print("   Calling dismiss...")
                        
                        // Try multiple ways to dismiss
                        presentationMode.wrappedValue.dismiss()
                        
                        // Force dismiss after a tiny delay if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if presentationMode.wrappedValue.isPresented {
                                print("   ⚠️ Still presented, trying again...")
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                        .frame(minWidth: 80, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    // Centered title
                    Text("Check Details")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Color.clear
                        .frame(width: 80, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(ThemeColorsConfig.backgroundDeep)
                .zIndex(100)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card
                        DetailHeaderCard(
                            session: session,
                            riskLevel: riskLevel,
                            appeared: appeared
                        )
                        .padding(.horizontal, 20)
                        
                        // Note Card
                        if let note = session.note, !note.isEmpty {
                            NoteCard(note: note, appeared: appeared)
                                .padding(.horizontal, 20)
                        }
                        
                        // Quick Stats Overview
                        QuickStatsOverview(session: session, appeared: appeared)
                            .padding(.horizontal, 20)
                        
                        // Stats Card
                        StatsCard(
                            session: session,
                            statsAppeared: statsAppeared
                        )
                        .padding(.horizontal, 20)
                        
                        // Symptoms Card
                        SymptomsCard(session: session, appeared: appeared)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("📱 HistoryDetailView appeared")
            print("   PresentationMode: \(presentationMode.wrappedValue.isPresented)")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            
            for i in 0..<5 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3 + Double(i) * 0.08)) {
                    statsAppeared[i] = true
                }
            }
        }
    }
}

// MARK: - Detail Header Card

struct DetailHeaderCard: View {
    let session: CheckSessionDTO
    let riskLevel: RiskLevel
    let appeared: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Risk Badge Large
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                riskLevel.color.opacity(0.3),
                                riskLevel.color.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 4) {
                    Image(systemName: riskLevel.iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(riskLevel.color)
                    
                    Text(riskLevel.shortName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(riskLevel.color)
                }
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            
            // Info
            VStack(spacing: 8) {
                Text(session.zone.displayName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text(riskLevel.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(riskLevel.color)
                
                Text(formattedDate(session.createdAt))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(riskLevel.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Quick Stats Overview

struct QuickStatsOverview: View {
    let session: CheckSessionDTO
    let appeared: Bool
    
    private var riskLevel: RiskLevel {
        RiskLevel(rawValue: session.riskLevel) ?? .low
    }
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatItem(
                icon: "gauge.medium",
                label: "Pain",
                value: "\(session.painNRS)/10",
                color: painColor(session.painNRS)
            )
            
            QuickStatItem(
                icon: "arrow.left.and.right",
                label: "ROM",
                value: "\(session.romPercent)%",
                color: romColor(session.romPercent)
            )
            
            QuickStatItem(
                icon: "chart.bar",
                label: "Risk",
                value: "\(session.riskScore)/12",
                color: riskLevel.color
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }
    
    private func painColor(_ pain: Int) -> Color {
        if pain <= 3 { return Color(hex: "34D399") }
        else if pain <= 6 { return Color(hex: "FFB84D") }
        else { return ThemeColorsConfig.accentWarm }
    }
    
    private func romColor(_ rom: Int) -> Color {
        if rom >= 75 { return Color(hex: "34D399") }
        else if rom >= 50 { return Color(hex: "FFB84D") }
        else { return ThemeColorsConfig.accentWarm }
    }
}

struct QuickStatItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ThemeColorsConfig.primaryLight)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ThemeColorsConfig.neutralAxis)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Note Card

struct NoteCard: View {
    let note: String
    let appeared: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ThemeColorsConfig.accentBright.opacity(0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "note.text")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.accentBright)
                }
                
                Text("Notes")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            Text(note)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.85))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(ThemeColorsConfig.accentBright.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
    }
}

// MARK: - Symptoms Card

struct SymptomsCard: View {
    let session: CheckSessionDTO
    let appeared: Bool
    
    private var symptoms: [(icon: String, label: String, present: Bool)] {
        [
            ("bed.double", "Pain at Rest", session.painRest),
            ("drop.fill", "Swelling", session.edema),
            ("flame.fill", "Warmth/Heat", session.heat),
            ("figure.fall", "Instability", session.instability),
            ("speaker.wave.3.fill", "Pop/Snap Sound", session.popSound),
            ("clock.fill", "Morning Stiffness", session.morningStiffness)
        ]
    }
    
    private var presentSymptoms: [(icon: String, label: String, present: Bool)] {
        symptoms.filter { $0.present }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(ThemeColorsConfig.accentWarm.opacity(0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.accentWarm)
                }
                
                Text("Active Symptoms")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                Text("\(presentSymptoms.count)/\(symptoms.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
            
            if presentSymptoms.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(Color(hex: "34D399"))
                        
                        Text("No Additional Symptoms")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(presentSymptoms, id: \.label) { symptom in
                        SymptomChip(icon: symptom.icon, label: symptom.label)
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(ThemeColorsConfig.accentWarm.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
}

struct SymptomChip: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(ThemeColorsConfig.accentWarm)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(ThemeColorsConfig.accentWarm.opacity(0.1))
        )
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let session: CheckSessionDTO
    let statsAppeared: [Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentBright)
                
                Text("Symptom Summary")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            VStack(spacing: 0) {
                StatRow(
                    icon: "gauge.medium",
                    label: "Pain Score",
                    value: "\(session.painNRS)/10",
                    progress: Double(session.painNRS) / 10.0,
                    isVisible: statsAppeared[0]
                )
                
                Divider()
                    .background(ThemeColorsConfig.neutralMuted.opacity(0.3))
                
                StatRow(
                    icon: "arrow.left.and.right",
                    label: "Range of Motion",
                    value: "\(session.romPercent)%",
                    progress: Double(session.romPercent) / 100.0,
                    isVisible: statsAppeared[1]
                )
                
                Divider()
                    .background(ThemeColorsConfig.neutralMuted.opacity(0.3))
                
                StatRowBool(
                    icon: "bed.double",
                    label: "Pain at Rest",
                    value: session.painRest,
                    isVisible: statsAppeared[2]
                )
                
                Divider()
                    .background(ThemeColorsConfig.neutralMuted.opacity(0.3))
                
                StatRowBool(
                    icon: "drop",
                    label: "Swelling",
                    value: session.edema,
                    isVisible: statsAppeared[3]
                )
                
                Divider()
                    .background(ThemeColorsConfig.neutralMuted.opacity(0.3))
                
                StatRow(
                    icon: "chart.bar",
                    label: "Risk Score",
                    value: "\(session.riskScore)/12",
                    progress: Double(session.riskScore) / 12.0,
                    isVisible: statsAppeared[4],
                    highlighted: true
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let progress: Double
    let isVisible: Bool
    var highlighted: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(highlighted ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.accentBright)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            
            Spacer()
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ThemeColorsConfig.neutralMuted.opacity(0.3))
                    
                    Capsule()
                        .fill(highlighted ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.accentBright)
                        .frame(width: isVisible ? geo.size.width * progress : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isVisible)
                }
            }
            .frame(width: 50, height: 6)
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(highlighted ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.primaryLight)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 14)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
    }
}

struct StatRowBool: View {
    let icon: String
    let label: String
    let value: Bool
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeColorsConfig.accentBright)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
            
            Spacer()
            
            HStack(spacing: 6) {
                Circle()
                    .fill(value ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.accentBright)
                    .frame(width: 8, height: 8)
                
                Text(value ? "Yes" : "No")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(value ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.primaryLight)
            }
        }
        .padding(.vertical, 14)
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -20)
    }
}

// MARK: - Zone Filter

struct ZoneFilterView: View {
    @Binding var selectedZone: ZoneDTO?
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentBright)
                
                Text("Filter by Zone")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                if selectedZone != nil {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedZone = nil
                            onSelect()
                        }
                    } label: {
                        Text("Clear")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ZoneDTO.allCases) { zone in
                        ZoneFilterChip(
                            zone: zone,
                            isSelected: selectedZone == zone,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedZone = (selectedZone == zone) ? nil : zone
                                    onSelect()
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ZoneFilterChip: View {
    let zone: ZoneDTO
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: zone.iconName)
                    .font(.system(size: 14, weight: .medium))
                
                Text(zone.displayName)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? ThemeColorsConfig.backgroundDeep : ThemeColorsConfig.primaryLight)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? ThemeColorsConfig.accentBright : ThemeColorsConfig.backgroundDeep.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stats Summary

struct StatsSummaryView: View {
    let items: [CheckSessionDTO]
    
    private var totalChecks: Int {
        items.count
    }
    
    private var averageRisk: Double {
        guard !items.isEmpty else { return 0 }
        let sum = items.reduce(0) { $0 + Double($1.riskScore) }
        return sum / Double(items.count)
    }
    
    private var highRiskCount: Int {
        // riskLevel: 0=low, 1=medium, 2=high, 3=critical
        items.filter { $0.riskLevel >= 2 }.count
    }
    
    private var averagePainScore: Double {
        guard !items.isEmpty else { return 0 }
        let sum = items.reduce(0) { $0 + Double($1.painNRS) }
        return sum / Double(items.count)
    }
    
    private var mostAffectedZone: ZoneDTO? {
        guard !items.isEmpty else { return nil }
        let zoneCounts = Dictionary(grouping: items, by: { $0.zone })
            .mapValues { $0.count }
        return zoneCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private var trendIndicator: (icon: String, color: Color, text: String) {
        guard items.count >= 2 else {
            return ("minus.circle.fill", ThemeColorsConfig.neutralAxis, "N/A")
        }
        
        // Compare first half vs second half
        let midpoint = items.count / 2
        let firstHalf = items.prefix(midpoint)
        let secondHalf = items.suffix(items.count - midpoint)
        
        let firstAvg = firstHalf.reduce(0) { $0 + Double($1.riskScore) } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + Double($1.riskScore) } / Double(secondHalf.count)
        
        if secondAvg < firstAvg - 0.5 {
            return ("arrow.down.circle.fill", Color(hex: "34D399"), "Improving")
        } else if secondAvg > firstAvg + 0.5 {
            return ("arrow.up.circle.fill", ThemeColorsConfig.accentWarm, "Worsening")
        } else {
            return ("equal.circle.fill", Color(hex: "FFB84D"), "Stable")
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // First row
            HStack(spacing: 12) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalChecks)",
                    label: "Total Checks",
                    color: ThemeColorsConfig.accentBright
                )
                
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: String(format: "%.1f", averageRisk),
                    label: "Avg Risk Score",
                    color: Color(hex: "FFB84D")
                )
            }
            
            // Second row
            HStack(spacing: 12) {
                StatCard(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(highRiskCount)",
                    label: "High Risk",
                    color: ThemeColorsConfig.accentWarm
                )
                
                StatCard(
                    icon: "gauge.medium",
                    value: String(format: "%.1f", averagePainScore),
                    label: "Avg Pain",
                    color: Color(hex: "A78BFA")
                )
            }
            
            // Trend and most affected zone
            HStack(spacing: 12) {
                // Trend card
                HStack(spacing: 10) {
                    Image(systemName: trendIndicator.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(trendIndicator.color)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trend")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                        
                        Text(trendIndicator.text)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ThemeColorsConfig.backgroundCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(trendIndicator.color.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Most affected zone
                if let zone = mostAffectedZone {
                    HStack(spacing: 10) {
                        Image(systemName: zone.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Most Checked")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(ThemeColorsConfig.neutralAxis)
                            
                            Text(zone.displayName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(ThemeColorsConfig.primaryLight)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(ThemeColorsConfig.backgroundCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(ThemeColorsConfig.accentBright.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(ThemeColorsConfig.primaryLight)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ThemeColorsConfig.neutralAxis)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Insights Card

struct InsightsCardView: View {
    let items: [CheckSessionDTO]
    
    private var insights: [Insight] {
        var result: [Insight] = []
        
        // Pain trend insight
        if items.count >= 3 {
            let recentPain = items.prefix(3).map { $0.painNRS }
            let avgRecentPain = Double(recentPain.reduce(0, +)) / Double(recentPain.count)
            
            if avgRecentPain > 6 {
                result.append(Insight(
                    icon: "exclamationmark.triangle.fill",
                    color: ThemeColorsConfig.accentWarm,
                    title: "High Pain Levels",
                    description: "Your recent checks show elevated pain. Consider consulting a healthcare professional."
                ))
            } else if avgRecentPain < 3 {
                result.append(Insight(
                    icon: "checkmark.seal.fill",
                    color: Color(hex: "34D399"),
                    title: "Pain Under Control",
                    description: "Great job! Your pain levels are well-managed."
                ))
            }
        }
        
        // ROM insight
        let avgROM = items.isEmpty ? 0 : items.reduce(0) { $0 + $1.romPercent } / items.count
        if avgROM < 50 {
            result.append(Insight(
                icon: "arrow.left.and.right.circle.fill",
                color: Color(hex: "FFB84D"),
                title: "Limited Mobility",
                description: "Your range of motion is restricted. Gentle stretching exercises may help."
            ))
        } else if avgROM > 80 {
            result.append(Insight(
                icon: "figure.flexibility",
                color: Color(hex: "34D399"),
                title: "Good Mobility",
                description: "Your range of motion is excellent. Keep up the good work!"
            ))
        }
        
        // Consistency insight
        if items.count >= 5 {
            result.append(Insight(
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                color: ThemeColorsConfig.accentBright,
                title: "Consistent Tracking",
                description: "You're doing great tracking your symptoms. This helps identify patterns."
            ))
        }
        
        // Rest pain insight
        let restPainCount = items.filter { $0.painRest }.count
        if restPainCount > items.count / 2 && !items.isEmpty {
            result.append(Insight(
                icon: "bed.double.fill",
                color: Color(hex: "A78BFA"),
                title: "Frequent Rest Pain",
                description: "You often experience pain at rest. This may indicate inflammation."
            ))
        }
        
        return result
    }
    
    var body: some View {
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(ThemeColorsConfig.accentBright.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                    }
                    
                    Text("Health Insights")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                }
                
                VStack(spacing: 12) {
                    ForEach(insights) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeColorsConfig.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        ThemeColorsConfig.accentBright.opacity(0.3),
                                        ThemeColorsConfig.neutralMuted.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }
}

struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let description: String
}

struct InsightRow: View {
    let insight: Insight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(insight.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: insight.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(insight.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text(insight.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(insight.color.opacity(0.05))
        )
    }
}

// Note: PressEventsModifier is now defined in ButtonStyles.swift
