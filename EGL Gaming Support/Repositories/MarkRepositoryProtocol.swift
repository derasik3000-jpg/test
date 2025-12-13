import Foundation

protocol GamingMarkRepositoryProtocol {
    func upsert(date: Date, delta: Int, note: String?) throws -> GamingMark
    func range(from: Date, to: Date) -> [GamingMark]
    func totalCount() -> Int32
}

