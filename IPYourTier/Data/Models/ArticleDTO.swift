import Foundation

public struct ArticleDTO: Identifiable {
    public let id: UUID
    public let slug: String
    public let title: String
    public let body: String
    public let tags: [String]
    public let updatedAt: Date
    public let externalURL: String?
    
    public init(
        id: UUID = UUID(),
        slug: String,
        title: String,
        body: String,
        tags: [String] = [],
        updatedAt: Date = Date(),
        externalURL: String? = nil
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.body = body
        self.tags = tags
        self.updatedAt = updatedAt
        self.externalURL = externalURL
    }
}

