import Foundation

public protocol BuildTimelineUC {
    func performInvocation(periodDays: Int?) -> X6TimelineModel
}

public class BuildTimelineUCImpl: BuildTimelineUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(periodDays: Int?) -> X6TimelineModel {
        let sessions: [CheckSessionDTO]
        
        if let days = periodDays {
            sessions = repository.recent(days: days)
        } else {
            sessions = repository.recent(days: 365)
        }
        
        var events: [X6Event] = []
        
        for session in sessions {
            if session.riskLevel == RiskLevel.red.rawValue {
                events.append(X6Event(
                    when: session.createdAt,
                    kind: "redFlag",
                    title: "Red Flag Detected",
                    detail: "\(session.zone.displayName) - Urgent attention needed"
                ))
            }
        }
        
        let sorted = sessions.sorted { $0.createdAt < $1.createdAt }
        for i in 1..<sorted.count {
            let prev = sorted[i-1]
            let curr = sorted[i]
            
            if curr.zone.rawValue == prev.zone.rawValue {
                if curr.riskLevel > prev.riskLevel {
                    let fromLevel = RiskLevel(rawValue: prev.riskLevel) ?? .low
                    let toLevel = RiskLevel(rawValue: curr.riskLevel) ?? .low
                    events.append(X6Event(
                        when: curr.createdAt,
                        kind: "escalated",
                        title: "Condition Worsened",
                        detail: "\(curr.zone.displayName): \(fromLevel) → \(toLevel)"
                    ))
                } else if curr.riskLevel < prev.riskLevel {
                    let fromLevel = RiskLevel(rawValue: prev.riskLevel) ?? .low
                    let toLevel = RiskLevel(rawValue: curr.riskLevel) ?? .low
                    events.append(X6Event(
                        when: curr.createdAt,
                        kind: "deescalated",
                        title: "Condition Improved",
                        detail: "\(curr.zone.displayName): \(fromLevel) → \(toLevel)"
                    ))
                }
            }
        }
        
        events.sort { $0.when > $1.when }
        
        let period: DateInterval?
        if let days = periodDays {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
            period = DateInterval(start: startDate, end: endDate)
        } else {
            period = nil
        }
        
        return X6TimelineModel(period: period, events: events)
    }
}

