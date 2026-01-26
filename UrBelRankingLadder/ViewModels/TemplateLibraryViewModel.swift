import Foundation
import Combine
@MainActor
final class TemplateLibraryViewModel: ObservableObject {
    @Published var templates: [SavedTemplateDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let templateRepository: SavedTemplateRepositoryProtocol
    private let applyTemplateUseCase: ApplySavedTemplateUseCase
    private let slotRepository: MealSlotRepositoryProtocol
    private let templateService: TemplateManagementServiceProtocol
    private let haptics: HapticFeedbackProvider
    
    init(
        templateRepository: SavedTemplateRepositoryProtocol,
        applyTemplateUseCase: ApplySavedTemplateUseCase,
        slotRepository: MealSlotRepositoryProtocol,
        templateService: TemplateManagementServiceProtocol,
        haptics: HapticFeedbackProvider = .shared
    ) {
        self.templateRepository = templateRepository
        self.applyTemplateUseCase = applyTemplateUseCase
        self.slotRepository = slotRepository
        self.templateService = templateService
        self.haptics = haptics
    }
    
    func loadTemplates() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            templates = try await templateRepository.fetchAllTemplates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createTemplateFromSlot(title: String, dayIdentifier: String, timeSlotRaw: String) async {
        do {
            let records = try await slotRepository.fetchRecords(dayIdentifier: dayIdentifier, timeSlotRaw: timeSlotRaw)
            let items = templateService.extractTemplateItems(from: records)
            
            _ = try await templateRepository.saveNewTemplate(
                templateTitle: title,
                itemsCollection: items,
                noteText: nil,
                timeSlotRaw: timeSlotRaw
            )
            
            await loadTemplates()
            successMessage = "Template saved!"
            haptics.triggerSuccess()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createTemplateFromSlotDetailed(title: String, note: String, dayIdentifier: String, timeSlotRaw: String) async {
        do {
            let records = try await slotRepository.fetchRecords(dayIdentifier: dayIdentifier, timeSlotRaw: timeSlotRaw)
            let items = templateService.extractTemplateItems(from: records)
            
            _ = try await templateRepository.saveNewTemplate(
                templateTitle: title,
                itemsCollection: items,
                noteText: note,
                timeSlotRaw: timeSlotRaw
            )
            
            await loadTemplates()
            successMessage = "Template saved!"
            haptics.triggerSuccess()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func applyTemplate(_ template: SavedTemplateDTO, dayIdentifier: String, timeSlotRaw: String) async {
        do {
            try await applyTemplateUseCase.execute(
                template: template,
                dayIdentifier: dayIdentifier,
                timeSlotRaw: timeSlotRaw
            )
            
            successMessage = "Template applied!"
            haptics.triggerSuccess()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTemplate(templateId: UUID) async {
        do {
            try await templateRepository.removeTemplate(templateIdentifier: templateId)
            await loadTemplates()
            haptics.triggerMediumImpact()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

