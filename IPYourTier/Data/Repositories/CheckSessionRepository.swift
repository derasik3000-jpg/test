import Foundation

public protocol CheckSessionRepository {
    func createIncomplete(zone: ZoneDTO, at: Date) -> CheckSessionDTO
    func updateAnswers(sessionId: UUID, answers: [String: Any]) -> CheckSessionDTO
    func complete(sessionId: UUID, riskScore: Int, riskLevel: Int, recommendationCode: Int) -> CheckSessionDTO
    func byId(_ id: UUID) -> CheckSessionDTO?
    func recent(days: Int) -> [CheckSessionDTO]
    func filter(zone: ZoneDTO?, from: Date, to: Date) -> [CheckSessionDTO]
    func setReminder(sessionId: UUID, at: Date?) -> CheckSessionDTO
    func setNote(sessionId: UUID, note: String?) -> CheckSessionDTO
    func expungeAll()
}

