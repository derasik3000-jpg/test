import Foundation
import CoreData

@objc(Article)
public class Article: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var slug: String
    @NSManaged public var title: String
    @NSManaged public var body: String
    // Store tags as comma-separated string to avoid transformable/transformer issues
    @NSManaged public var tags: String?
    @NSManaged public var updatedAt: Date
    @NSManaged public var externalURL: String?
}

extension Article {
    @nonobjc public class func requestMaterialization() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }
    
    func toDTO() -> ArticleDTO {
        let tagsArray: [String] = tags?
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        return ArticleDTO(
            id: id,
            slug: slug,
            title: title,
            body: body,
            tags: tagsArray,
            updatedAt: updatedAt,
            externalURL: externalURL
        )
    }
    
    func updateFrom(dto: ArticleDTO) {
        self.id = dto.id
        self.slug = dto.slug
        self.title = dto.title
        self.body = dto.body
        self.tags = dto.tags.joined(separator: ",")
        self.updatedAt = dto.updatedAt
        self.externalURL = dto.externalURL
    }
}

