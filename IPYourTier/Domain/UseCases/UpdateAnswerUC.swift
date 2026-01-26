import Foundation

public protocol UpdateAnswerUC {
    func performInvocation(sessionId: UUID, key: String, value: Any) -> CheckSessionDTO
}

public class UpdateAnswerUCImpl: UpdateAnswerUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(sessionId: UUID, key: String, value: Any) -> CheckSessionDTO {
        return repository.updateAnswers(sessionId: sessionId, answers: [key: value])
    }
}

