import Foundation
import CoreData

class CoreDataQuantumEntryRepository: QuantumEntryRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadEntriesCatalog(for sphereId: UUID, filter: EntryFilterCriteria, sort: EntrySortOrder) async throws -> [QuantumProgressEntry] {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            var predicates: [NSPredicate] = [NSPredicate(format: "cosmicSphereLink.zephyrId == %@", sphereId as CVarArg)]
            
            switch filter {
            case .all:
                break
            case .beforeAfter:
                predicates.append(NSPredicate(format: "morphicTypeValue == %d", 0))
            case .stages:
                predicates.append(NSPredicate(format: "morphicTypeValue == %d", 1))
            case .pinned:
                predicates.append(NSPredicate(format: "pinnacleFixedFlag == YES"))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            switch sort {
            case .dateDescending:
                request.sortDescriptors = [NSSortDescriptor(keyPath: \AdvancementRecord.temporalEventMoment, ascending: false)]
            case .dateAscending:
                request.sortDescriptors = [NSSortDescriptor(keyPath: \AdvancementRecord.temporalEventMoment, ascending: true)]
            case .titleAscending:
                request.sortDescriptors = [NSSortDescriptor(keyPath: \AdvancementRecord.prismaticTitleText, ascending: true)]
            }
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { self.mapAdvancementRecordToDomainEntry($0) }
        }
    }
    
    func loadEntryById(id: UUID) async throws -> QuantumProgressEntry {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first,
                  let entry = self.mapAdvancementRecordToDomainEntry(entity) else {
                throw AuroraFluxError.notFound
            }
            return entry
        }
    }
    
    func insertBeforeAfterEntryRecord(sphereId: UUID, title: String?, note: String?, eventDate: Date, tags: [String], beforePhotoPath: String, afterPhotoPath: String?, afterSelfRating: Int?) async throws -> QuantumProgressEntry {
        try await context.perform {
            let sphereRequest = CategoryRecord.fetchRequest()
            sphereRequest.predicate = NSPredicate(format: "zephyrId == %@", sphereId as CVarArg)
            guard let sphere = try self.context.fetch(sphereRequest).first else {
                throw AuroraFluxError.notFound
            }
            
            let entity = AdvancementRecord(context: self.context)
            entity.zephyrId = UUID()
            entity.morphicTypeValue = 0
            entity.prismaticTitleText = title
            entity.chronicleNoteContent = note
            entity.temporalEventMoment = eventDate
            entity.stellarCreatedTimestamp = Date()
            entity.galaxyUpdatedTimestamp = Date()
            entity.pinnacleFixedFlag = false
            entity.luminousAfterScore = Int16(afterSelfRating ?? 0)
            entity.cosmicSphereLink = sphere
            
            let beforePhoto = ImageRecord(context: self.context)
            beforePhoto.zephyrId = UUID()
            beforePhoto.dimensionalRoleTag = 0
            beforePhoto.vortexStoragePath = beforePhotoPath
            beforePhoto.temporalCaptureInstant = Date()
            beforePhoto.sequentialOrderIndex = 0
            beforePhoto.cosmicProgressAnchor = entity
            
            if let afterPhotoPath = afterPhotoPath {
                let afterPhoto = ImageRecord(context: self.context)
                afterPhoto.zephyrId = UUID()
                afterPhoto.dimensionalRoleTag = 1
                afterPhoto.vortexStoragePath = afterPhotoPath
                afterPhoto.temporalCaptureInstant = Date()
                afterPhoto.sequentialOrderIndex = 1
                afterPhoto.cosmicProgressAnchor = entity
            }
            
            for tagName in tags {
                let tagRequest = LabelRecord.fetchRequest()
                tagRequest.predicate = NSPredicate(format: "lexicalNameString == %@", tagName)
                
                let tag: LabelRecord
                if let existingTag = try self.context.fetch(tagRequest).first {
                    tag = existingTag
                } else {
                    tag = LabelRecord(context: self.context)
                    tag.zephyrId = UUID()
                    tag.lexicalNameString = tagName
                    tag.stellarCreatedTimestamp = Date()
                }
                entity.addToSemanticLabelTokens(tag)
            }
            
            try self.context.save()
            return self.mapAdvancementRecordToDomainEntry(entity)!
        }
    }
    
    func insertStagesEntryRecord(sphereId: UUID, title: String?, note: String?, eventDate: Date, tags: [String], stagePhotoPaths: [String]) async throws -> QuantumProgressEntry {
        try await context.perform {
            let sphereRequest = CategoryRecord.fetchRequest()
            sphereRequest.predicate = NSPredicate(format: "zephyrId == %@", sphereId as CVarArg)
            guard let sphere = try self.context.fetch(sphereRequest).first else {
                throw AuroraFluxError.notFound
            }
            
            let entity = AdvancementRecord(context: self.context)
            entity.zephyrId = UUID()
            entity.morphicTypeValue = 1
            entity.prismaticTitleText = title
            entity.chronicleNoteContent = note
            entity.temporalEventMoment = eventDate
            entity.stellarCreatedTimestamp = Date()
            entity.galaxyUpdatedTimestamp = Date()
            entity.pinnacleFixedFlag = false
            entity.luminousAfterScore = 0
            entity.cosmicSphereLink = sphere
            
            for (index, path) in stagePhotoPaths.enumerated() {
                let photo = ImageRecord(context: self.context)
                photo.zephyrId = UUID()
                photo.dimensionalRoleTag = 2
                photo.vortexStoragePath = path
                photo.temporalCaptureInstant = Date()
                photo.sequentialOrderIndex = Int16(index)
                photo.cosmicProgressAnchor = entity
            }
            
            for tagName in tags {
                let tagRequest = LabelRecord.fetchRequest()
                tagRequest.predicate = NSPredicate(format: "lexicalNameString == %@", tagName)
                
                let tag: LabelRecord
                if let existingTag = try self.context.fetch(tagRequest).first {
                    tag = existingTag
                } else {
                    tag = LabelRecord(context: self.context)
                    tag.zephyrId = UUID()
                    tag.lexicalNameString = tagName
                    tag.stellarCreatedTimestamp = Date()
                }
                entity.addToSemanticLabelTokens(tag)
            }
            
            try self.context.save()
            return self.mapAdvancementRecordToDomainEntry(entity)!
        }
    }
    
    func attachAfterPhotoToEntry(entryId: UUID, afterPhotoPath: String, afterSelfRating: Int?) async throws -> QuantumProgressEntry {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", entryId as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            let afterPhoto = ImageRecord(context: self.context)
            afterPhoto.zephyrId = UUID()
            afterPhoto.dimensionalRoleTag = 1
            afterPhoto.vortexStoragePath = afterPhotoPath
            afterPhoto.temporalCaptureInstant = Date()
            afterPhoto.sequentialOrderIndex = 1
            afterPhoto.cosmicProgressAnchor = entity
            
            if let rating = afterSelfRating {
                entity.luminousAfterScore = Int16(rating)
            }
            entity.galaxyUpdatedTimestamp = Date()
            
            try self.context.save()
            return self.mapAdvancementRecordToDomainEntry(entity)!
        }
    }
    
    func appendStagePhotosToEntry(entryId: UUID, stagePhotoPaths: [String]) async throws -> QuantumProgressEntry {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", entryId as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            let existingPhotos = (entity.spectrumImageFragments?.allObjects as? [ImageRecord]) ?? []
            let maxIndex = existingPhotos.map(\.sequentialOrderIndex).max() ?? -1
            
            for (offset, path) in stagePhotoPaths.enumerated() {
                let photo = ImageRecord(context: self.context)
                photo.zephyrId = UUID()
                photo.dimensionalRoleTag = 2
                photo.vortexStoragePath = path
                photo.temporalCaptureInstant = Date()
                photo.sequentialOrderIndex = maxIndex + Int16(offset) + 1
                photo.cosmicProgressAnchor = entity
            }
            
            entity.galaxyUpdatedTimestamp = Date()
            try self.context.save()
            return self.mapAdvancementRecordToDomainEntry(entity)!
        }
    }
    
    func updateEntryMetadata(id: UUID, title: String?, note: String?, eventDate: Date?, isPinned: Bool?, tags: [String]?) async throws -> QuantumProgressEntry {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            if let title = title {
                entity.prismaticTitleText = title
            }
            if let note = note {
                entity.chronicleNoteContent = note
            }
            if let eventDate = eventDate {
                entity.temporalEventMoment = eventDate
            }
            if let isPinned = isPinned {
                entity.pinnacleFixedFlag = isPinned
            }
            if let tags = tags {
                entity.removeFromSemanticLabelTokens(entity.semanticLabelTokens ?? NSSet())
                
                for tagName in tags {
                    let tagRequest = LabelRecord.fetchRequest()
                    tagRequest.predicate = NSPredicate(format: "lexicalNameString == %@", tagName)
                    
                    let tag: LabelRecord
                    if let existingTag = try self.context.fetch(tagRequest).first {
                        tag = existingTag
                    } else {
                        tag = LabelRecord(context: self.context)
                        tag.zephyrId = UUID()
                        tag.lexicalNameString = tagName
                        tag.stellarCreatedTimestamp = Date()
                    }
                    entity.addToSemanticLabelTokens(tag)
                }
            }
            
            entity.galaxyUpdatedTimestamp = Date()
            try self.context.save()
            return self.mapAdvancementRecordToDomainEntry(entity)!
        }
    }
    
    func removeEntryById(id: UUID) async throws {
        try await context.perform {
            let request = AdvancementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    private func mapAdvancementRecordToDomainEntry(_ entity: AdvancementRecord) -> QuantumProgressEntry? {
        guard let id = entity.zephyrId,
              let sphereId = entity.cosmicSphereLink?.zephyrId,
              let eventDate = entity.temporalEventMoment,
              let created = entity.stellarCreatedTimestamp,
              let updated = entity.galaxyUpdatedTimestamp else {
            return nil
        }
        
        let photos = (entity.spectrumImageFragments?.allObjects as? [ImageRecord] ?? [])
            .sorted { $0.sequentialOrderIndex < $1.sequentialOrderIndex }
            .compactMap { photo -> SpectrumPhotoItem? in
                guard let photoId = photo.zephyrId,
                      let path = photo.vortexStoragePath else {
                    return nil
                }
                return SpectrumPhotoItem(
                    id: photoId,
                    dimensionalRoleTag: SpectrumPhotoItem.PhotoRoleType(rawValue: Int(photo.dimensionalRoleTag)) ?? .before,
                    vortexStoragePath: path,
                    miniatureThumbnailPath: photo.miniatureThumbnailPath,
                    temporalCaptureInstant: photo.temporalCaptureInstant,
                    sequentialOrderIndex: Int(photo.sequentialOrderIndex),
                    pixelWidthDimension: photo.pixelWidthDimension != 0 ? Int(photo.pixelWidthDimension) : nil,
                    pixelHeightDimension: photo.pixelHeightDimension != 0 ? Int(photo.pixelHeightDimension) : nil
                )
            }
        
        let tags = (entity.semanticLabelTokens?.allObjects as? [LabelRecord] ?? [])
            .compactMap { $0.lexicalNameString }
        
        return QuantumProgressEntry(
            id: id,
            sphereId: sphereId,
            morphicTypeValue: QuantumProgressEntry.ProgressTypeEnum(rawValue: Int(entity.morphicTypeValue)) ?? .beforeAfter,
            prismaticTitleText: entity.prismaticTitleText,
            chronicleNoteContent: entity.chronicleNoteContent,
            temporalEventMoment: eventDate,
            stellarCreatedTimestamp: created,
            galaxyUpdatedTimestamp: updated,
            pinnacleFixedFlag: entity.pinnacleFixedFlag,
            luminousAfterScore: entity.luminousAfterScore != 0 ? Int(entity.luminousAfterScore) : nil,
            photoFragments: photos,
            semanticTags: tags
        )
    }
}

