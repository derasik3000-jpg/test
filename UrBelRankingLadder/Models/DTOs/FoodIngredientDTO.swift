import Foundation

public struct FoodIngredientDTO: Identifiable, Hashable, Codable {
    public let id: UUID
    public let titleText: String
    public let descriptionHint: String?
    public let categoryRaw: String
    public let isUserCreated: Bool
    
    public init(id: UUID, titleText: String, descriptionHint: String?, categoryRaw: String, isUserCreated: Bool) {
        self.id = id
        self.titleText = titleText
        self.descriptionHint = descriptionHint
        self.categoryRaw = categoryRaw
        self.isUserCreated = isUserCreated
    }
}

