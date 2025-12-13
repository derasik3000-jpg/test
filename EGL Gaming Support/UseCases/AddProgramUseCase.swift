import Foundation

class AddGamingProgramUseCase {
    private let repository: GamingProgramRepositoryProtocol
    
    init(repository: GamingProgramRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ draft: GamingProgramDraft) throws -> GamingProgram {
        return try repository.create(draft)
    }
}

