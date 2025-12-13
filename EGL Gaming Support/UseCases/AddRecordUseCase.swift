import Foundation

class AddGamingRecordUseCase {
    private let repository: GamingRecordRepositoryProtocol
    
    init(repository: GamingRecordRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ draft: GamingRecordDraft) throws -> GamingRecord {
        return try repository.create(draft)
    }
}

