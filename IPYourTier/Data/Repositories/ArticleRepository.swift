import Foundation

public protocol ArticleRepository {
    func all() -> [ArticleDTO]
    func bySlug(_ slug: String) -> ArticleDTO?
    func search(_ query: String) -> [ArticleDTO]
}

