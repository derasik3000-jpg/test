import Foundation

protocol NebulaSphereRepository {
    func loadActiveSpheresCatalog() async throws -> [NebulaSphere]
    func loadAllSpheresCatalog() async throws -> [NebulaSphere]
    func insertSphereRecord(title: String, kind: NebulaSphere.SphereKindType, coverPhotoPath: String?) async throws -> NebulaSphere
    func updateSphereRecord(id: UUID, title: String?, sortOrder: Int?, coverPhotoPath: String?, showInRadar: Bool?) async throws -> NebulaSphere
    func markSphereAsArchived(id: UUID) async throws
    func markSphereAsRestored(id: UUID) async throws
    func persistSphereSortOrdering(idsInOrder: [UUID]) async throws
}

enum EntryFilterCriteria {
    case all
    case beforeAfter
    case stages
    case pinned
}

enum EntrySortOrder {
    case dateDescending
    case dateAscending
    case titleAscending
}

protocol QuantumEntryRepository {
    func loadEntriesCatalog(for sphereId: UUID, filter: EntryFilterCriteria, sort: EntrySortOrder) async throws -> [QuantumProgressEntry]
    func loadEntryById(id: UUID) async throws -> QuantumProgressEntry
    func insertBeforeAfterEntryRecord(sphereId: UUID, title: String?, note: String?, eventDate: Date, tags: [String], beforePhotoPath: String, afterPhotoPath: String?, afterSelfRating: Int?) async throws -> QuantumProgressEntry
    func insertStagesEntryRecord(sphereId: UUID, title: String?, note: String?, eventDate: Date, tags: [String], stagePhotoPaths: [String]) async throws -> QuantumProgressEntry
    func attachAfterPhotoToEntry(entryId: UUID, afterPhotoPath: String, afterSelfRating: Int?) async throws -> QuantumProgressEntry
    func appendStagePhotosToEntry(entryId: UUID, stagePhotoPaths: [String]) async throws -> QuantumProgressEntry
    func updateEntryMetadata(id: UUID, title: String?, note: String?, eventDate: Date?, isPinned: Bool?, tags: [String]?) async throws -> QuantumProgressEntry
    func removeEntryById(id: UUID) async throws
}

protocol VortexPhotoRepository {
    func persistOriginalPhotoData(imageData: Data, preferredName: String?) async throws -> String
    func persistThumbnailForPhoto(at localPath: String) async throws -> String
    func removePhotoFile(at localPath: String) async throws
}

protocol SemanticTagRepository {
    func loadAllTagStrings() async throws -> [String]
    func suggestTagStrings(prefix: String) async throws -> [String]
    func upsertTagStrings(names: [String]) async throws
}

protocol EtherealMilestoneRepository {
    func loadMilestonesCatalog(for sphereId: UUID) async throws -> [EtherealMilestone]
    func insertMilestoneRecord(sphereId: UUID, title: String, note: String?, date: Date, linkedEntryId: UUID?) async throws -> EtherealMilestone
    func updateMilestoneRecord(id: UUID, title: String?, note: String?, date: Date?, linkedEntryId: UUID?) async throws -> EtherealMilestone
    func removeMilestoneById(id: UUID) async throws
}

protocol AuroraAnalyticsRepository {
    func computeDonutDataset(range: ChronoTimeRange, mode: CosmicDonutData.VisualizationMode) async throws -> CosmicDonutData
    func computeBarDataset(range: ChronoTimeRange, granularity: TemporalBarData.TimeGranularity, scope: AnalyticsScope) async throws -> TemporalBarData
    func computeTimelineDataset(range: ChronoTimeRange, scope: AnalyticsScope) async throws -> ChronicleTimelineData
}

