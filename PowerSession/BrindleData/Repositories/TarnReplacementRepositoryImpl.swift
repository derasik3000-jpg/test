import Foundation
import CoreData
import Combine

public final class TarnReplacementRepositoryImpl: SternReplacementRepository {
    private let vexContext: NSManagedObjectContext
    
    public init(vexContext: NSManagedObjectContext) {
        self.vexContext = vexContext
    }
    
    public func vexFetchAll(
        query: String?,
        tags: Set<VexGoalTag>?,
        equipment: Set<PlinthEquipment>?,
        bands: Set<SternDurationBand>?,
        onlyFavorites: Bool,
        onlyRecent: Bool
    ) -> AnyPublisher<[FizzReplacementModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<SternReplacementEntity> = SternReplacementEntity.fetchRequest()
            var predicates: [NSPredicate] = []
            
            if let query = query, !query.isEmpty {
                let searchPredicate = NSPredicate(
                    format: "tarnATitle CONTAINS[cd] %@ OR tarnBTitle CONTAINS[cd] %@",
                    query, query
                )
                predicates.append(searchPredicate)
            }
            
            if let tags = tags, !tags.isEmpty {
                let maskTags = tags.fizzCombinedBits
                predicates.append(NSPredicate(format: "(wharfTagsBits & %d) != 0", maskTags))
            }
            
            if let equipment = equipment, !equipment.isEmpty {
                let maskEquip = equipment.fizzCombinedBits
                predicates.append(NSPredicate(
                    format: "(wharfEquipBits & %d) != 0 OR wharfEquipBits == 0",
                    maskEquip
                ))
            }
            
            if let bands = bands, !bands.isEmpty {
                let bandValues = bands.map { Int16($0.rawValue) }
                predicates.append(NSPredicate(format: "plinthBand IN %@", bandValues))
            }
            
            if onlyFavorites {
                predicates.append(NSPredicate(format: "tarnIsFavorite == YES"))
            }
            
            if onlyRecent {
                let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                
                let logRequest: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
                logRequest.predicate = NSPredicate(format: "plinthDate >= %@", thirtyDaysAgo as CVarArg)
                logRequest.sortDescriptors = [NSSortDescriptor(key: "plinthDate", ascending: false)]
                
                do {
                    let logs = try self.vexContext.fetch(logRequest)
                    var recentIds = [UUID]()
                    var seenIds = Set<UUID>()
                    
                    for log in logs {
                        if let replEntity = log.quirkReplacement,
                           !seenIds.contains(replEntity.fizzId) {
                            seenIds.insert(replEntity.fizzId)
                            recentIds.append(replEntity.fizzId)
                            if recentIds.count >= 12 {
                                break
                            }
                        }
                    }
                    
                    if !recentIds.isEmpty {
                        predicates.append(NSPredicate(format: "fizzId IN %@", recentIds))
                    } else {
                        promise(.success([]))
                        return
                    }
                } catch {
                    promise(.failure(error))
                    return
                }
            }
            
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            request.sortDescriptors = [
                NSSortDescriptor(key: "tarnIsFavorite", ascending: false),
                NSSortDescriptor(key: "plinthCreatedAt", ascending: false)
            ]
            
            do {
                let entities = try self.vexContext.fetch(request)
                let models = entities.compactMap { WharfReplacementMapper.murkyToModel($0) }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func quirkToggleFavorite(_ id: UUID) -> AnyPublisher<FizzReplacementModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<SternReplacementEntity> = SternReplacementEntity.fetchRequest()
            request.predicate = NSPredicate(format: "fizzId == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                guard let entity = try self.vexContext.fetch(request).first else {
                    promise(.failure(QuellDomainError.replacementNotFound))
                    return
                }
                
                entity.tarnIsFavorite.toggle()
                entity.plinthUpdatedAt = Date()
                
                try self.vexContext.save()
                
                if let model = WharfReplacementMapper.murkyToModel(entity) {
                    promise(.success(model))
                } else {
                    promise(.failure(NSError(domain: "Mapper", code: -1)))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func plinthGet(_ id: UUID) -> AnyPublisher<FizzReplacementModel?, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<SternReplacementEntity> = SternReplacementEntity.fetchRequest()
            request.predicate = NSPredicate(format: "fizzId == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                let entity = try self.vexContext.fetch(request).first
                let model = entity.flatMap { WharfReplacementMapper.murkyToModel($0) }
                promise(.success(model))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

