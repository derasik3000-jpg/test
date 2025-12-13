import Foundation

class AddGamingPlanUseCase {
    private let planRepository: GamingPlanRepositoryProtocol
    private let notificationService: GamingNotificationServiceProtocol
    
    init(planRepository: GamingPlanRepositoryProtocol, notificationService: GamingNotificationServiceProtocol) {
        self.planRepository = planRepository
        self.notificationService = notificationService
    }
    
    func execute(_ draft: GamingPlanDraft) throws -> GamingPlan {
        let plan = try planRepository.create(draft)
        
        if let programId = draft.refId, draft.planType == "program" {
            notificationService.schedulePlanReminder(planId: plan.id, date: draft.planDate, programId: programId)
        } else if let recordId = draft.refId, draft.planType == "record" {
            notificationService.schedulePlanReminder(planId: plan.id, date: draft.planDate, recordId: recordId)
        }
        
        return plan
    }
}

