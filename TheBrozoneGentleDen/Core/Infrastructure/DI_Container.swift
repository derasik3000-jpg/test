import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    private lazy var persistence = DataStorageManager.shared
    
    lazy var sphereRepository: NebulaSphereRepository = CoreDataNebulaSphereRepository(context: persistence.viewContext)
    lazy var entryRepository: QuantumEntryRepository = CoreDataQuantumEntryRepository(context: persistence.viewContext)
    lazy var photoRepository: VortexPhotoRepository = LocalVortexPhotoRepository()
    lazy var tagRepository: SemanticTagRepository = CoreDataSemanticTagRepository(context: persistence.viewContext)
    lazy var milestoneRepository: EtherealMilestoneRepository = CoreDataEtherealMilestoneRepository(context: persistence.viewContext)
    lazy var analyticsRepository: AuroraAnalyticsRepository = CoreDataAuroraAnalyticsRepository(context: persistence.viewContext)
    
    lazy var initializeDefaultSpheresUseCase: InitializeDefaultSpheresUseCase = InitializeDefaultSpheresUseCaseImpl(sphereRepo: sphereRepository)
    lazy var createBeforeAfterUseCase: CreateBeforeAfterEntryUseCase = CreateBeforeAfterEntryUseCaseImpl(entryRepo: entryRepository, photoRepo: photoRepository)
    lazy var addAfterPhotoUseCase: AddAfterPhotoUseCase = AddAfterPhotoUseCaseImpl(entryRepo: entryRepository, photoRepo: photoRepository)
    lazy var createStagesUseCase: CreateStagesEntryUseCase = CreateStagesEntryUseCaseImpl(entryRepo: entryRepository, photoRepo: photoRepository)
    lazy var getRadarOverviewUseCase: GetRadarOverviewUseCase = GetRadarOverviewUseCaseImpl(analyticsRepo: analyticsRepository)
    lazy var getSphereTimelineUseCase: GetSphereTimelineUseCase = GetSphereTimelineUseCaseImpl(analyticsRepo: analyticsRepository)
    lazy var reorderSpheresUseCase: ReorderSpheresUseCase = ReorderSpheresUseCaseImpl(sphereRepo: sphereRepository)
}

