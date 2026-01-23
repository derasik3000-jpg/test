import Foundation
import CoreData

protocol EnvelopeRepository {
    func list(weekId: UUID) throws -> [WeekEnvelope]
    func upsertNames(weekId: UUID, names: [String]) throws -> [WeekEnvelope]
    func updateSum(weekEnvelopeId: UUID, sumCents: Int64) throws
    func byId(_ id: UUID) throws -> WeekEnvelope?
}

final class EnvelopeRepositoryImpl: EnvelopeRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func list(weekId: UUID) throws -> [WeekEnvelope] {
        let fetchRequest: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
    
    func upsertNames(weekId: UUID, names: [String]) throws -> [WeekEnvelope] {
        let fetchRequest: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        let existingEntities = try context.fetch(fetchRequest)
        
        // Update existing envelopes
        for (index, entity) in existingEntities.enumerated() where index < names.count {
            entity.name = names[index]
            entity.orderIndex = Int16(index)
        }
        
        // Add new envelopes if names.count > existing
        if names.count > existingEntities.count {
            let weekFetch: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
            weekFetch.predicate = NSPredicate(format: "id == %@", weekId as CVarArg)
            let weekEntity = try context.fetch(weekFetch).first
            
            for index in existingEntities.count..<names.count {
                let newEntity = WeekEnvelopeEntity(context: context)
                newEntity.id = UUID()
                newEntity.weekId = weekId
                newEntity.orderIndex = Int16(index)
                newEntity.name = names[index]
                newEntity.sumCents = 0
                newEntity.week = weekEntity
            }
        }
        
        // Remove excess envelopes if names.count < existing
        if names.count < existingEntities.count {
            for index in names.count..<existingEntities.count {
                context.delete(existingEntities[index])
            }
        }
        
        try context.save()
        
        // Fetch updated list
        let updatedFetch: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        updatedFetch.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        updatedFetch.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return try context.fetch(updatedFetch).map { $0.toDomain() }
    }
    
    func updateSum(weekEnvelopeId: UUID, sumCents: Int64) throws {
        let fetchRequest: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", weekEnvelopeId as CVarArg)
        
        if let entity = try context.fetch(fetchRequest).first {
            entity.sumCents = sumCents
            try context.save()
        }
    }
    
    func byId(_ id: UUID) throws -> WeekEnvelope? {
        let fetchRequest: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(fetchRequest).first?.toDomain()
    }
}

extension WeekEnvelopeEntity {
    func toDomain() -> WeekEnvelope {
        return WeekEnvelope(
            id: id ?? UUID(),
            weekId: weekId ?? UUID(),
            orderIndex: orderIndex,
            name: name ?? "",
            sumCents: sumCents
        )
    }
    
    func fromDomain(_ domain: WeekEnvelope) {
        self.id = domain.id
        self.weekId = domain.weekId
        self.orderIndex = domain.orderIndex
        self.name = domain.name
        self.sumCents = domain.sumCents
    }
}

