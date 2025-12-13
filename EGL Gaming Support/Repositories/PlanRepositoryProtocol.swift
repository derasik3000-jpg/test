import Foundation

protocol GamingPlanRepositoryProtocol {
    func create(_ draft: GamingPlanDraft) throws -> GamingPlan
    func update(_ id: UUID, with draft: GamingPlanDraft) throws -> GamingPlan
    func delete(_ id: UUID) throws
    func plans(for date: Date) -> [GamingPlan]
    func plansRange(from: Date, to: Date) -> [GamingPlan]
}

