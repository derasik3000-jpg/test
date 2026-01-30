import Foundation
import CoreData
import Combine

public final class QuellAppliedLogRepositoryImpl: WharfAppliedLogRepository {
    private let fizzContext: NSManagedObjectContext
    
    public init(fizzContext: NSManagedObjectContext) {
        self.fizzContext = fizzContext
    }
    
    public func brindleApply(
        replacementId: UUID,
        variantId: UUID?,
        note: String?,
        date: Date
    ) -> AnyPublisher<SprocketAppliedLogModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            do {
                let replRequest: NSFetchRequest<SternReplacementEntity> = SternReplacementEntity.fetchRequest()
                replRequest.predicate = NSPredicate(format: "fizzId == %@", replacementId as CVarArg)
                replRequest.fetchLimit = 1
                
                guard let replEntity = try self.fizzContext.fetch(replRequest).first else {
                    promise(.failure(QuellDomainError.replacementNotFound))
                    return
                }
                
                var variantEntity: MurkyVariantEntity? = nil
                if let variantId = variantId {
                    let varRequest: NSFetchRequest<MurkyVariantEntity> = MurkyVariantEntity.fetchRequest()
                    varRequest.predicate = NSPredicate(format: "fizzId == %@", variantId as CVarArg)
                    varRequest.fetchLimit = 1
                    variantEntity = try self.fizzContext.fetch(varRequest).first
                }
                
                let logEntity = FizzAppliedLogEntity(context: self.fizzContext)
                logEntity.fizzId = UUID()
                logEntity.plinthDate = date
                logEntity.tarnNote = note
                logEntity.quirkReplacement = replEntity
                logEntity.quirkVariant = variantEntity
                
                try self.fizzContext.save()
                
                guard let replModel = WharfReplacementMapper.murkyToModel(replEntity) else {
                    promise(.failure(NSError(domain: "Mapper", code: -1)))
                    return
                }
                
                let variantModel = variantEntity.flatMap { PlinthVariantMapper.vexToModel($0) }
                
                let logModel = SprocketAppliedLogModel(
                    id: logEntity.fizzId,
                    plinthDate: logEntity.plinthDate,
                    quirkReplacement: replModel,
                    quirkVariant: variantModel,
                    tarnNote: logEntity.tarnNote
                )
                
                promise(.success(logModel))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func tarnFetchRange(from: Date, to: Date) -> AnyPublisher<[SprocketAppliedLogModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "plinthDate >= %@ AND plinthDate < %@", from as CVarArg, to as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "plinthDate", ascending: false)]
            
            do {
                let entities = try self.fizzContext.fetch(request)
                let models = entities.compactMap { entity -> SprocketAppliedLogModel? in
                    guard let replEntity = entity.quirkReplacement,
                          let replModel = WharfReplacementMapper.murkyToModel(replEntity) else {
                        return nil
                    }
                    
                    let variantModel = entity.quirkVariant.flatMap { PlinthVariantMapper.vexToModel($0) }
                    
                    return SprocketAppliedLogModel(
                        id: entity.fizzId,
                        plinthDate: entity.plinthDate,
                        quirkReplacement: replModel,
                        quirkVariant: variantModel,
                        tarnNote: entity.tarnNote
                    )
                }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func fizzDelete(_ id: UUID) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.predicate = NSPredicate(format: "fizzId == %@", id as CVarArg)
            request.fetchLimit = 1
            
            do {
                if let entity = try self.fizzContext.fetch(request).first {
                    self.fizzContext.delete(entity)
                    try self.fizzContext.save()
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func quellRecent(limit: Int) -> AnyPublisher<[SprocketAppliedLogModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }
            
            let request: NSFetchRequest<FizzAppliedLogEntity> = FizzAppliedLogEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "plinthDate", ascending: false)]
            request.fetchLimit = limit
            
            do {
                let entities = try self.fizzContext.fetch(request)
                let models = entities.compactMap { entity -> SprocketAppliedLogModel? in
                    guard let replEntity = entity.quirkReplacement,
                          let replModel = WharfReplacementMapper.murkyToModel(replEntity) else {
                        return nil
                    }
                    
                    let variantModel = entity.quirkVariant.flatMap { PlinthVariantMapper.vexToModel($0) }
                    
                    return SprocketAppliedLogModel(
                        id: entity.fizzId,
                        plinthDate: entity.plinthDate,
                        quirkReplacement: replModel,
                        quirkVariant: variantModel,
                        tarnNote: entity.tarnNote
                    )
                }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

