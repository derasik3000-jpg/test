import Foundation
import CoreData

protocol WeekRepository {
    func currentOrCreate(now: Date, boundaryHour: Int) throws -> Week
    func byId(_ id: UUID) throws -> Week?
    func range(from: Date, to: Date) throws -> [Week]
    func save(_ week: Week) throws
    func allWeeks() throws -> [Week]
}

final class WeekRepositoryImpl: WeekRepository {
    private let context: NSManagedObjectContext
    private let weekService: WeekService
    
    init(context: NSManagedObjectContext, weekService: WeekService) {
        self.context = context
        self.weekService = weekService
    }
    
    func currentOrCreate(now: Date, boundaryHour: Int) throws -> Week {
        let (year, week) = weekService.isoYearWeek(for: now, boundaryHour: boundaryHour)
        
        let fetchRequest: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isoYear == %d AND isoWeek == %d", year, week)
        
        if let entity = try context.fetch(fetchRequest).first {
            return entity.toDomain()
        }
        
        let newWeek = Week(isoYear: Int16(year), isoWeek: Int16(week), status: 0, createdAt: now)
        let entity = WeekEntity(context: context)
        entity.fromDomain(newWeek)
        
        let defaultNames = ["Food", "Transport", "Other"]
        for (index, name) in defaultNames.enumerated() {
            let envEntity = WeekEnvelopeEntity(context: context)
            envEntity.id = UUID()
            envEntity.weekId = newWeek.id
            envEntity.orderIndex = Int16(index)
            envEntity.name = name
            envEntity.sumCents = 0
            envEntity.week = entity
        }
        
        try context.save()
        return newWeek
    }
    
    func byId(_ id: UUID) throws -> Week? {
        let fetchRequest: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(fetchRequest).first?.toDomain()
    }
    
    func range(from: Date, to: Date) throws -> [Week] {
        let fetchRequest: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", from as CVarArg, to as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
    
    func allWeeks() throws -> [Week] {
        let fetchRequest: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
    
    func save(_ week: Week) throws {
        let fetchRequest: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", week.id as CVarArg)
        
        if let entity = try context.fetch(fetchRequest).first {
            entity.fromDomain(week)
            try context.save()
        }
    }
}

extension WeekEntity {
    func toDomain() -> Week {
        return Week(
            id: id ?? UUID(),
            isoYear: isoYear,
            isoWeek: isoWeek,
            status: status,
            createdAt: createdAt ?? Date(),
            closedAt: closedAt,
            sumCents: sumCents,
            maxDeltaPct: maxDeltaPct
        )
    }
    
    func fromDomain(_ domain: Week) {
        self.id = domain.id
        self.isoYear = domain.isoYear
        self.isoWeek = domain.isoWeek
        self.status = domain.status
        self.createdAt = domain.createdAt
        self.closedAt = domain.closedAt
        self.sumCents = domain.sumCents
        self.maxDeltaPct = domain.maxDeltaPct
    }
}

