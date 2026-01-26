import Foundation

public class ProvisionRegistry {
    public static let shared = ProvisionRegistry()
    
    private let persistenceStack = PersistenceStackController.shared
    
    public lazy var checkSessionRepo: CheckSessionRepository = {
        CheckSessionRepositoryImpl(stack: persistenceStack)
    }()
    
    public lazy var articleRepo: ArticleRepository = {
        ArticleRepositoryImpl(stack: persistenceStack)
    }()
    
    public lazy var settingsRepo: SettingsRepository = {
        PreferenceDataStore(stack: persistenceStack)
    }()
    
    public lazy var notificationScheduler: NotificationScheduler = {
        NotificationSchedulerImpl()
    }()
    
    public lazy var startCheckUC: StartCheckUC = {
        StartCheckUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var updateAnswerUC: UpdateAnswerUC = {
        UpdateAnswerUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var completeCheckUC: CompleteCheckUC = {
        CompleteCheckUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var scheduleFollowUpUC: ScheduleFollowUpUC = {
        ScheduleFollowUpUCImpl(repository: checkSessionRepo, scheduler: notificationScheduler)
    }()
    
    public lazy var buildRiskDonutUC: BuildRiskDonutUC = {
        BuildRiskDonutUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var buildRiskPieUC: BuildRiskPieUC = {
        BuildRiskPieUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var buildRiskBarUC: BuildRiskBarUC = {
        BuildRiskBarUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var buildTimelineUC: BuildTimelineUC = {
        BuildTimelineUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var buildFeatureStackedUC: BuildFeatureStackedUC = {
        BuildFeatureStackedUCImpl(repository: checkSessionRepo)
    }()
    
    public lazy var libraryVM: LibraryVM = {
        LibraryVM(repo: articleRepo)
    }()
    
    public lazy var historyVM: HistoryVM = {
        HistoryVM(repo: checkSessionRepo, barUC: buildRiskBarUC, pieUC: buildRiskPieUC)
    }()
    
    private init() {}
}

