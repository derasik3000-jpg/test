import Foundation
import CoreData

protocol BadgeRepository {
    func insert(_ b: Badge) throws
    func byWeek(_ weekId: UUID) throws -> [Badge]
}

final class BadgeRepositoryImpl: BadgeRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func insert(_ b: Badge) throws {
        let entity = BadgeEntity(context: context)
        entity.fromDomain(b)
        try context.save()
    }
    
    func byWeek(_ weekId: UUID) throws -> [Badge] {
        let fetchRequest: NSFetchRequest<BadgeEntity> = BadgeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
}

extension BadgeEntity {
    func toDomain() -> Badge {
        return Badge(
            id: id ?? UUID(),
            weekId: weekId ?? UUID(),
            kind: kind,
            achievedAt: achievedAt ?? Date()
        )
    }
    
    func fromDomain(_ domain: Badge) {
        self.id = domain.id
        self.weekId = domain.weekId
        self.kind = domain.kind
        self.achievedAt = domain.achievedAt
    }
}

