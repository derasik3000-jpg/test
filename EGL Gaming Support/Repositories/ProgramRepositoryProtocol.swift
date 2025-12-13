import Foundation

protocol GamingProgramRepositoryProtocol {
    func create(_ draft: GamingProgramDraft) throws -> GamingProgram
    func update(_ id: UUID, with draft: GamingProgramDraft) throws -> GamingProgram
    func delete(_ id: UUID) throws
    func active() -> [GamingProgram]
    func search(query: String) -> [GamingProgram]
    func byId(_ id: UUID) -> GamingProgram?
}

