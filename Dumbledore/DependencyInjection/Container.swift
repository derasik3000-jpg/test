// Container.swift
import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Repositories
    lazy var scenarioRepository: ScenarioRepository = MockScenarioRepository()
    lazy var dialogSessionRepository: DialogSessionRepository = MockDialogSessionRepository()
    lazy var immersionRepository: ImmersionRepository = MockImmersionRepository()
    lazy var microLessonRepository: MicroLessonRepository = MockMicroLessonRepository()
    lazy var weakSpotRepository: WeakSpotRepository = MockWeakSpotRepository()
    lazy var vocabularyRepository: VocabularyRepository = MockVocabularyRepository()
    lazy var progressRepository: ProgressRepository = MockProgressRepository()
    lazy var settingsRepository: SettingsRepository = MockSettingsRepository()
    lazy var interestRepository: InterestRepository = MockInterestRepository()
    
    // MARK: - Adapters
    lazy var speechAdapter: SpeechAdapter = SpeechAdapterImpl()
    lazy var ttsAdapter: TTSAdapter = TTSAdapterImpl()
    lazy var notificationAdapter: NotificationAdapter = NotificationAdapterImpl()
    
    // MARK: - Use Cases
    lazy var startDialogUseCase: StartDialogUseCase = StartDialogUseCaseImpl(
        sessionRepository: dialogSessionRepository
    )
    
    lazy var handleUserUtteranceUseCase: HandleUserUtteranceUseCase = HandleUserUtteranceUseCaseImpl(
        sessionRepository: dialogSessionRepository,
        vocabularyRepository: vocabularyRepository
    )
    
    lazy var finishDialogUseCase: FinishDialogUseCase = FinishDialogUseCaseImpl(
        sessionRepository: dialogSessionRepository
    )
    
    lazy var buildImmersionFeedUseCase: BuildImmersionFeedUseCase = BuildImmersionFeedUseCaseImpl(
        immersionRepository: immersionRepository
    )
    
    lazy var generateMicroLessonUseCase: GenerateMicroLessonUseCase = GenerateMicroLessonUseCaseImpl(
        microLessonRepository: microLessonRepository,
        weakSpotRepository: weakSpotRepository,
        vocabularyRepository: vocabularyRepository
    )
    
    lazy var completeMicroLessonUseCase: CompleteMicroLessonUseCase = CompleteMicroLessonUseCaseImpl(
        microLessonRepository: microLessonRepository,
        vocabularyRepository: vocabularyRepository
    )
    
    lazy var buildUsefulDonutUseCase: BuildUsefulDonutUseCase = BuildUsefulDonutUseCaseImpl(
        progressRepository: progressRepository
    )
    
    lazy var buildTopicPieUseCase: BuildTopicPieUseCase = BuildTopicPieUseCaseImpl(
        progressRepository: progressRepository
    )
    
    lazy var buildBarSeriesUseCase: BuildBarSeriesUseCase = BuildBarSeriesUseCaseImpl(
        progressRepository: progressRepository
    )
    
    lazy var buildWeakHeatmapUseCase: BuildWeakHeatmapUseCase = BuildWeakHeatmapUseCaseImpl(
        progressRepository: progressRepository
    )
}
