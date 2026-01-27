import SwiftUI

struct ArchiveTabView: View {
    @StateObject var viewModel: ArchiveViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDeep
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Spacer()
                        
                        Text("Archive")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(AppTheme.surfaceDark)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            headerSection
                            
                            statsSection
                            
                            calendarSection
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadHistory()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Progress")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Track your deload history")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Statistics", icon: "chart.bar.fill")
            
            if let stats = viewModel.stats {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "calendar.badge.clock",
                            value: "\(stats.totalWeeks)",
                            label: "Total Weeks",
                            accentColor: AppTheme.goldPrimary
                        )
                        
                        StatCard(
                            icon: "arrow.down.right",
                            value: "–\(stats.averageReduction)%",
                            label: "Avg Reduction",
                            accentColor: AppTheme.successGreen
                        )
                    }
                    
                    if let lastDate = stats.lastDeloadDate {
                        StreakCard(
                            lastDate: lastDate,
                            currentStreak: stats.currentStreak,
                            recommendationText: stats.recommendationText,
                            recommendationColor: Color(hex: stats.recommendationColor)
                        )
                    } else {
                        EmptyStateCard()
                    }
                }
            } else {
                EmptyStateCard()
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calendar Section
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Calendar", icon: "calendar")
            
            CalendarGridView(completedDates: viewModel.completedDates)
        }
        .padding(.horizontal)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.goldPrimary)
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.goldDark.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(accentColor)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
        )
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let lastDate: Date
    let currentStreak: Int
    let recommendationText: String
    let recommendationColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Current Streak")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                // Streak badge
                Text("\(currentStreak)d")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.backgroundDeep)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(AppTheme.goldGradient)
                    )
            }
            
            Divider()
                .background(AppTheme.dividerTint)
            
            // Stats row
            HStack(spacing: 20) {
                StreakStatItem(
                    value: "\(currentStreak)",
                    label: "Days",
                    icon: "calendar"
                )
                
                StreakStatItem(
                    value: lastDate.formatted(.dateTime.month(.abbreviated).day()),
                    label: "Last Deload",
                    icon: "clock.arrow.circlepath"
                )
                
                Spacer()
            }
            
            // Recommendation
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(recommendationColor)
                
                Text(recommendationText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(recommendationColor)
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(recommendationColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(recommendationColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.goldDark.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct StreakStatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.goldDark)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
    }
}

// MARK: - Empty State Card

struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.goldPrimary.opacity(0.1))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.goldDark)
            }
            
            VStack(spacing: 6) {
                Text("No Deload Weeks Yet")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Start your first deload week\nto see statistics here")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
        )
    }
}

// MARK: - Calendar Grid View

struct CalendarGridView: View {
    let completedDates: Set<Date>
    @State private var currentMonth = Date()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.goldPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppTheme.goldPrimary.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text(currentMonth, formatter: monthFormatter)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.goldPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppTheme.goldPrimary.opacity(0.1))
                        )
                }
            }
            
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)
                        .frame(height: 32)
                }
            }
            
            // Days grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isCompleted: isDateCompleted(date),
                            isToday: Calendar.current.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
        )
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return completedDates.contains(dayStart)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth),
              let start = Optional(interval.start),
              let end = Optional(interval.end) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: start)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        var current = start
        while current < end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        return days
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            if isToday {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppTheme.goldPrimary, lineWidth: 2)
            }
            
            if isCompleted {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.successGreen.opacity(0.2))
            }
            
            // Content
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(isToday ? AppTheme.goldPrimary : AppTheme.textPrimary)
                
                if isCompleted {
                    Circle()
                        .fill(AppTheme.successGreen)
                        .frame(width: 5, height: 5)
                }
            }
        }
        .frame(height: 44)
    }
}
