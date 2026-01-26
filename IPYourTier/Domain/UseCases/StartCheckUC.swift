import Foundation

public protocol StartCheckUC {
    func performInvocation(zone: ZoneDTO, now: Date) -> CheckSessionDTO
}

public class StartCheckUCImpl: StartCheckUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(zone: ZoneDTO, now: Date) -> CheckSessionDTO {
        return repository.createIncomplete(zone: zone, at: now)
    }
}

