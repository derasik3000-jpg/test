import Foundation
import CoreData

protocol EntryRepository {
    func create(_ e: Entry) throws
    func update(_ e: Entry) throws
    func delete(id: UUID) throws
    func lastOfWeek(_ weekId: UUID) throws -> Entry?
    func byWeek(_ weekId: UUID) throws -> [Entry]
    func byWeekDay(_ weekId: UUID, dayKey: Int) throws -> [Entry]
}

final class EntryRepositoryImpl: EntryRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create(_ e: Entry) throws {
        let entity = EntryEntity(context: context)
        entity.id = e.id
        entity.weekId = e.weekId
        entity.envelopeId = e.envelopeId
        entity.amountCents = e.amountCents
        entity.note = e.note
        entity.at = e.at
        entity.dayKey = e.dayKey
        entity.wasUndone = e.wasUndone
        
        // Установить relationships
        let weekFetch: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        weekFetch.predicate = NSPredicate(format: "id == %@", e.weekId as CVarArg)
        if let weekEntity = try context.fetch(weekFetch).first {
            entity.week = weekEntity
        }
        
        let envelopeFetch: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        envelopeFetch.predicate = NSPredicate(format: "id == %@", e.envelopeId as CVarArg)
        if let envelopeEntity = try context.fetch(envelopeFetch).first {
            entity.envelope = envelopeEntity
        }
        
        try context.save()
        try recalculateSums(weekId: e.weekId)
    }
    
    func update(_ e: Entry) throws {
        let fetchRequest: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", e.id as CVarArg)
        
        if let entity = try context.fetch(fetchRequest).first {
            entity.amountCents = e.amountCents
            entity.note = e.note
            entity.at = e.at
            entity.dayKey = e.dayKey
            entity.wasUndone = e.wasUndone
            
            // Обновить relationships если изменились
            if entity.weekId != e.weekId {
                entity.weekId = e.weekId
                let weekFetch: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
                weekFetch.predicate = NSPredicate(format: "id == %@", e.weekId as CVarArg)
                if let weekEntity = try context.fetch(weekFetch).first {
                    entity.week = weekEntity
                }
            }
            
            if entity.envelopeId != e.envelopeId {
                entity.envelopeId = e.envelopeId
                let envelopeFetch: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
                envelopeFetch.predicate = NSPredicate(format: "id == %@", e.envelopeId as CVarArg)
                if let envelopeEntity = try context.fetch(envelopeFetch).first {
                    entity.envelope = envelopeEntity
                }
            }
            
            try context.save()
            try recalculateSums(weekId: e.weekId)
        }
    }
    
    func delete(id: UUID) throws {
        let fetchRequest: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(fetchRequest).first {
            let weekId = entity.weekId ?? UUID()
            context.delete(entity)
            try context.save()
            try recalculateSums(weekId: weekId)
        }
    }
    
    func lastOfWeek(_ weekId: UUID) throws -> Entry? {
        let fetchRequest: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "at", ascending: false)]
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first?.toDomain()
    }
    
    func byWeek(_ weekId: UUID) throws -> [Entry] {
        let fetchRequest: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "at", ascending: false)]
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
    
    func byWeekDay(_ weekId: UUID, dayKey: Int) throws -> [Entry] {
        let fetchRequest: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "weekId == %@ AND dayKey == %d", weekId as CVarArg, dayKey)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "at", ascending: false)]
        return try context.fetch(fetchRequest).map { $0.toDomain() }
    }
    
    private func recalculateSums(weekId: UUID) throws {
        let entriesFetch: NSFetchRequest<EntryEntity> = EntryEntity.fetchRequest()
        entriesFetch.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        let entries = try context.fetch(entriesFetch)
        
        var envelopeSums: [UUID: Int64] = [:]
        for entry in entries {
            if let envId = entry.envelopeId {
                envelopeSums[envId, default: 0] += entry.amountCents
            }
        }
        
        let envelopesFetch: NSFetchRequest<WeekEnvelopeEntity> = WeekEnvelopeEntity.fetchRequest()
        envelopesFetch.predicate = NSPredicate(format: "weekId == %@", weekId as CVarArg)
        let envelopes = try context.fetch(envelopesFetch)
        
        for envelope in envelopes {
            if let envId = envelope.id {
                envelope.sumCents = envelopeSums[envId] ?? 0
            }
        }
        
        let weekFetch: NSFetchRequest<WeekEntity> = WeekEntity.fetchRequest()
        weekFetch.predicate = NSPredicate(format: "id == %@", weekId as CVarArg)
        if let weekEntity = try context.fetch(weekFetch).first {
            weekEntity.sumCents = envelopes.reduce(0) { $0 + $1.sumCents }
        }
        
        try context.save()
    }
}

extension EntryEntity {
    func toDomain() -> Entry {
        return Entry(
            id: id ?? UUID(),
            weekId: weekId ?? UUID(),
            envelopeId: envelopeId ?? UUID(),
            amountCents: amountCents,
            note: note,
            at: at ?? Date(),
            dayKey: dayKey,
            wasUndone: wasUndone
        )
    }
    
    func fromDomain(_ domain: Entry) {
        self.id = domain.id
        self.weekId = domain.weekId
        self.envelopeId = domain.envelopeId
        self.amountCents = domain.amountCents
        self.note = domain.note
        self.at = domain.at
        self.dayKey = domain.dayKey
        self.wasUndone = domain.wasUndone
    }
}

