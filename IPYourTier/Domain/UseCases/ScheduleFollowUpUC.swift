import Foundation

public protocol ScheduleFollowUpUC {
    func performInvocation(sessionId: UUID, at: Date)
}

public class ScheduleFollowUpUCImpl: ScheduleFollowUpUC {
    private let repository: CheckSessionRepository
    private let scheduler: NotificationScheduler
    
    public init(repository: CheckSessionRepository, scheduler: NotificationScheduler) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    public func performInvocation(sessionId: UUID, at: Date) {
        guard let session = repository.byId(sessionId) else { return }
        
        if session.riskLevel == RiskLevel.red.rawValue || session.riskLevel == RiskLevel.high.rawValue {
            return
        }
        
        _ = repository.setReminder(sessionId: sessionId, at: at)
        
        scheduler.scheduleOnce(
            at: at,
            title: "Time to Recheck",
            body: "Review your \(session.zone.displayName) symptoms",
            userInfo: ["sessionId": sessionId.uuidString]
        )
    }
}

