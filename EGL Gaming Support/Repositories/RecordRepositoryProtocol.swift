import Foundation

protocol GamingRecordRepositoryProtocol {
    func create(_ draft: GamingRecordDraft) throws -> GamingRecord
    func update(_ id: UUID, with draft: GamingRecordDraft) throws -> GamingRecord
    func archive(_ id: UUID) throws
    func delete(_ id: UUID) throws
    func active() -> [GamingRecord]
    func search(query: String) -> [GamingRecord]
}

