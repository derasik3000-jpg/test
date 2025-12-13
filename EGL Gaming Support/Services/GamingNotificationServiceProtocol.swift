import Foundation

protocol GamingNotificationServiceProtocol {
    func schedulePlanReminder(planId: UUID, date: Date, programId: UUID?)
    func schedulePlanReminder(planId: UUID, date: Date, recordId: UUID?)
    func cancelPlanReminder(planId: UUID)
    func requestAuthorization() async -> Bool
}

