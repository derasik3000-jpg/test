import Foundation
import SwiftUI
import Combine

@MainActor
class GamingCalendarViewModel: ObservableObject {
    @Published var plans: [GamingPlan] = []
    @Published var selectedDate: Date = Date()
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var showingAddModal: Bool = false
    @Published var editingPlan: GamingPlan?
    
    private let planRepository: GamingPlanRepositoryProtocol
    private let addUseCase: AddGamingPlanUseCase
    private let programRepository: GamingProgramRepositoryProtocol
    private let recordRepository: GamingRecordRepositoryProtocol
    
    init(
        planRepository: GamingPlanRepositoryProtocol,
        addUseCase: AddGamingPlanUseCase,
        programRepository: GamingProgramRepositoryProtocol,
        recordRepository: GamingRecordRepositoryProtocol
    ) {
        self.planRepository = planRepository
        self.addUseCase = addUseCase
        self.programRepository = programRepository
        self.recordRepository = recordRepository
    }
    
    func loadPlans() {
        isLoading = true
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        plans = planRepository.plansRange(from: startOfMonth, to: endOfMonth)
        isLoading = false
    }
    
    func plansForDate(_ date: Date) -> [GamingPlan] {
        return planRepository.plans(for: date)
    }
    
    func addPlan(date: Date, type: String, refId: UUID?, note: String?) throws {
        let draft = GamingPlanDraft(planDate: date, planType: type, refId: refId, note: note)
        _ = try addUseCase.execute(draft)
        loadPlans()
    }
    
    func updatePlan(_ plan: GamingPlan, date: Date, type: String, refId: UUID?, note: String?) throws {
        let draft = GamingPlanDraft(planDate: date, planType: type, refId: refId, note: note)
        _ = try planRepository.update(plan.id, with: draft)
        loadPlans()
    }
    
    func deletePlan(_ plan: GamingPlan) throws {
        try planRepository.delete(plan.id)
        loadPlans()
    }
    
    func startEdit(_ plan: GamingPlan) {
        editingPlan = plan
        showingAddModal = true
    }
    
    func getProgramName(for plan: GamingPlan) -> String {
        guard plan.planType == "program", let refId = plan.refId else { return "" }
        return programRepository.byId(refId)?.name ?? ""
    }
    
    func getRecordText(for plan: GamingPlan) -> String {
        guard plan.planType == "record", let refId = plan.refId else { return "" }
        return recordRepository.active().first { $0.id == refId }?.text ?? ""
    }
    
    func getRecord(for plan: GamingPlan) -> GamingRecord? {
        guard plan.planType == "record", let refId = plan.refId else { return nil }
        return recordRepository.active().first { $0.id == refId }
    }
    
    func getProgram(for plan: GamingPlan) -> GamingProgram? {
        guard plan.planType == "program", let refId = plan.refId else { return nil }
        return programRepository.byId(refId)
    }
    
    func recordsWithPhotosForDate(_ date: Date) -> [GamingRecord] {
        let allRecords = recordRepository.active()
        return allRecords.filter { record in
            guard let imageData = record.imageData, !imageData.isEmpty else { return false }
            guard let recordDate = record.recordDate else { return false }
            return Calendar.current.isDate(recordDate, inSameDayAs: date)
        }
    }
}

