import Foundation

protocol WeekService {
    func isoYearWeek(for date: Date, boundaryHour: Int) -> (year: Int, week: Int)
    func dayKey(for date: Date, boundaryHour: Int) -> Int
    func weekStart(year: Int, week: Int) -> Date
}

final class WeekServiceImpl: WeekService {
    
    func isoYearWeek(for date: Date, boundaryHour: Int) -> (year: Int, week: Int) {
        let adjustedDate = applyBoundary(date: date, boundaryHour: boundaryHour)
        let calendar = Calendar(identifier: .iso8601)
        let year = calendar.component(.yearForWeekOfYear, from: adjustedDate)
        let week = calendar.component(.weekOfYear, from: adjustedDate)
        return (year, week)
    }
    
    func dayKey(for date: Date, boundaryHour: Int) -> Int {
        let adjustedDate = applyBoundary(date: date, boundaryHour: boundaryHour)
        let calendar = Calendar(identifier: .iso8601)
        let weekday = calendar.component(.weekday, from: adjustedDate)
        return (weekday == 1) ? 6 : weekday - 2
    }
    
    func weekStart(year: Int, week: Int) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = DateComponents()
        components.yearForWeekOfYear = year
        components.weekOfYear = week
        components.weekday = 2
        return calendar.date(from: components) ?? Date()
    }
    
    private func applyBoundary(date: Date, boundaryHour: Int) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour < boundaryHour {
            return calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return date
    }
}

