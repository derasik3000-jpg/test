import Foundation
import Combine
import SwiftUI

final class StatisticsViewModel: ObservableObject {
    @Published var totalSpending: String = "0"
    @Published var totalWeeks: Int = 0
    @Published var averagePerWeek: String = "0"
    @Published var topEnvelopes: [(name: String, total: String)] = []
    @Published var weeksWithBadges: Int = 0
    @Published var currentStreak: Int = 0
    @Published var pieChartData: [(name: String, value: Double, color: Color)] = []
    @Published var barChartData: [(name: String, value: Double, color: Color)] = []
    
    private let weekRepo: WeekRepository
    private let envRepo: EnvelopeRepository
    private let badgeRepo: BadgeRepository
    private let entryRepo: EntryRepository
    private let formatter: CurrencyFormatter
    
    init(weekRepo: WeekRepository, envRepo: EnvelopeRepository, badgeRepo: BadgeRepository, 
         entryRepo: EntryRepository, formatter: CurrencyFormatter) {
        self.weekRepo = weekRepo
        self.envRepo = envRepo
        self.badgeRepo = badgeRepo
        self.entryRepo = entryRepo
        self.formatter = formatter
    }
    
    func load() {
        guard let weeks = try? weekRepo.allWeeks() else { return }
        
        totalWeeks = weeks.count
        let total = weeks.reduce(0) { $0 + $1.sumCents }
        totalSpending = formatter.string(fromCents: total)
        
        if totalWeeks > 0 {
            let avg = total / Int64(totalWeeks)
            averagePerWeek = formatter.string(fromCents: avg)
        }
        
        var envelopeTotals: [String: Int64] = [:]
        for week in weeks {
            if let envelopes = try? envRepo.list(weekId: week.id) {
                for envelope in envelopes {
                    envelopeTotals[envelope.name, default: 0] += envelope.sumCents
                }
            }
        }
        
        topEnvelopes = envelopeTotals.sorted { $0.value > $1.value }
            .prefix(5)
            .map { (name: $0.key, total: formatter.string(fromCents: $0.value)) }
        
        weeksWithBadges = weeks.filter { week in
            if let badges = try? badgeRepo.byWeek(week.id) {
                return !badges.isEmpty
            }
            return false
        }.count
        
        let sortedWeeks = weeks.sorted { $0.createdAt > $1.createdAt }
        var streak = 0
        for week in sortedWeeks {
            if let badges = try? badgeRepo.byWeek(week.id), !badges.isEmpty {
                streak += 1
            } else {
                break
            }
        }
        currentStreak = streak
        
        // Pie chart data
        let totalEnvelopeValue = envelopeTotals.values.reduce(0, +)
        if totalEnvelopeValue > 0 {
            let colors: [Color] = [
                ColorTheme.Accent.accent500,
                ColorTheme.Balance.medium,
                ColorTheme.Balance.ok,
                Color.purple,
                Color.blue
            ]
            pieChartData = envelopeTotals.sorted { $0.value > $1.value }
                .prefix(5)
                .enumerated()
                .map { index, item in
                    let percentage = (Double(item.value) / Double(totalEnvelopeValue)) * 100.0
                    return (name: item.key, value: percentage, color: colors[index % colors.count])
                }
        }
        
        // Bar chart data - last 4 weeks (including empty weeks)
        if !weeks.isEmpty {
            let newestWeek = sortedWeeks.first!
            var barData: [(name: String, value: Double, color: Color)] = []
            
            for weekOffset in 0..<4 {
                // Calculate which week this should be
                let targetYear = newestWeek.isoYear
                let targetWeek = Int(newestWeek.isoWeek) - weekOffset
                
                // Find week in our data
                if let weekData = weeks.first(where: { $0.isoYear == targetYear && $0.isoWeek == Int16(targetWeek) }) {
                    let amount = Double(weekData.sumCents) / 100.0
                    let color = weekOffset == 0 ? ColorTheme.Accent.accent500 : ColorTheme.Balance.medium
                    barData.append((name: "W\(weekData.isoWeek)", value: amount, color: color))
                } else {
                    // Week doesn't exist - show as 0
                    let color = weekOffset == 0 ? ColorTheme.Accent.accent500 : ColorTheme.Balance.medium
                    barData.append((name: "W\(targetWeek)", value: 0.0, color: color))
                }
            }
            
            barChartData = barData.reversed()
        }
    }
}

