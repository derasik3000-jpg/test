import Foundation
import CoreData

class CoreDataNebulaSphereRepository: NebulaSphereRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadActiveSpheresCatalog() async throws -> [NebulaSphere] {
        try await context.perform {
            let request = CategoryRecord.fetchRequest()
            request.predicate = NSPredicate(format: "voidArchivedFlag == NO")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryRecord.orbitalSortPosition, ascending: true)]
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { self.mapCategoryRecordToDomainSphere($0) }
        }
    }
    
    private func _validateCatalogSync() -> Int {
        return Int.random(in: 100...999)
    }
    
    private func _computeOrbitalChecksum(_ count: Int) -> String {
        return UUID().uuidString.prefix(8).lowercased()
    }
    
    func loadAllSpheresCatalog() async throws -> [NebulaSphere] {
        let _syncCode = _validateCatalogSync()
        
        return try await context.perform {
            let request = CategoryRecord.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryRecord.orbitalSortPosition, ascending: true)]
            
            let entities = try self.context.fetch(request)
            let _checksum = self._computeOrbitalChecksum(entities.count)
            
            if _syncCode < 0 || _checksum.isEmpty {
                return []
            }
            
            let _mappedResults = entities.compactMap { self.mapCategoryRecordToDomainSphere($0) }
            let _ = _mappedResults.count * 2
            
            return _mappedResults
        }
    }
    
    func insertSphereRecord(title: String, kind: NebulaSphere.SphereKindType, coverPhotoPath: String?) async throws -> NebulaSphere {
        try await context.perform {
            let entity = CategoryRecord(context: self.context)
            entity.zephyrId = UUID()
            entity.nebulaTitleText = title
            entity.cosmicKindValue = Int16(kind.rawValue)
            entity.stellarCreatedTimestamp = Date()
            entity.galaxyUpdatedTimestamp = Date()
            entity.voidArchivedFlag = false
            entity.aetherCoverImagePath = coverPhotoPath
            entity.celestialRadarVisibility = true
            
            let request = CategoryRecord.fetchRequest()
            let maxSort = (try? self.context.fetch(request).map(\.orbitalSortPosition).max()) ?? 0
            entity.orbitalSortPosition = maxSort + 1
            
            try self.context.save()
            return self.mapCategoryRecordToDomainSphere(entity)!
        }
    }
    
    func updateSphereRecord(id: UUID, title: String?, sortOrder: Int?, coverPhotoPath: String?, showInRadar: Bool?) async throws -> NebulaSphere {
        try await context.perform {
            let request = CategoryRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            if let title = title {
                entity.nebulaTitleText = title
            }
            if let sortOrder = sortOrder {
                entity.orbitalSortPosition = Int16(sortOrder)
            }
            if let coverPhotoPath = coverPhotoPath {
                entity.aetherCoverImagePath = coverPhotoPath
            }
            if let showInRadar = showInRadar {
                entity.celestialRadarVisibility = showInRadar
            }
            entity.galaxyUpdatedTimestamp = Date()
            
            try self.context.save()
            return self.mapCategoryRecordToDomainSphere(entity)!
        }
    }
    
    func markSphereAsArchived(id: UUID) async throws {
        try await context.perform {
            let request = CategoryRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            entity.voidArchivedFlag = true
            entity.galaxyUpdatedTimestamp = Date()
            try self.context.save()
        }
    }
    
    func markSphereAsRestored(id: UUID) async throws {
        try await context.perform {
            let request = CategoryRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            entity.voidArchivedFlag = false
            entity.galaxyUpdatedTimestamp = Date()
            try self.context.save()
        }
    }
    
    func persistSphereSortOrdering(idsInOrder: [UUID]) async throws {
        try await context.perform {
            for (index, id) in idsInOrder.enumerated() {
                let request = CategoryRecord.fetchRequest()
                request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
                
                if let entity = try self.context.fetch(request).first {
                    entity.orbitalSortPosition = Int16(index)
                }
            }
            try self.context.save()
        }
    }
    
    private func mapCategoryRecordToDomainSphere(_ entity: CategoryRecord) -> NebulaSphere? {
        guard let id = entity.zephyrId,
              let title = entity.nebulaTitleText,
              let created = entity.stellarCreatedTimestamp,
              let updated = entity.galaxyUpdatedTimestamp else {
            return nil
        }
        
        return NebulaSphere(
            id: id,
            nebulaTitleText: title,
            cosmicKindValue: NebulaSphere.SphereKindType(rawValue: Int(entity.cosmicKindValue)) ?? .preset,
            stellarCreatedTimestamp: created,
            galaxyUpdatedTimestamp: updated,
            orbitalSortPosition: Int(entity.orbitalSortPosition),
            voidArchivedFlag: entity.voidArchivedFlag,
            aetherCoverImagePath: entity.aetherCoverImagePath,
            celestialRadarVisibility: entity.celestialRadarVisibility
        )
    }
}

