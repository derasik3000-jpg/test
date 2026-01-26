import Foundation

protocol SavedTemplateRepositoryProtocol {
    func fetchAllTemplates() async throws -> [SavedTemplateDTO]
    func saveNewTemplate(templateTitle: String, itemsCollection: [TemplateIngredientItem], noteText: String?, timeSlotRaw: String?) async throws -> SavedTemplateDTO
    func updateTemplate(templateIdentifier: UUID, templateTitle: String?, itemsCollection: [TemplateIngredientItem]?) async throws
    func removeTemplate(templateIdentifier: UUID) async throws
}

