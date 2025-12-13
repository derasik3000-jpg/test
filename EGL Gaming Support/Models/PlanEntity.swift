import Foundation

struct GamingPlanDraft {
    var planDate: Date
    var planType: String
    var refId: UUID?
    var note: String?
}

struct GamingPlan {
    let id: UUID
    var planDate: Date
    var planType: String
    var refId: UUID?
    var note: String?
    let createdAt: Date
    var updatedAt: Date
}

