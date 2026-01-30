import Foundation

public protocol MurkyDateProvider {
    var plinthNow: Date { get }
    func vexWeekStart(for date: Date) -> Date
}

public final class SternDefaultDateProvider: MurkyDateProvider {
    public init() {}
    
    public var plinthNow: Date {
        Date()
    }
    
    public func vexWeekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}

