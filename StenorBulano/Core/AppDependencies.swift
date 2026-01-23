import Foundation
import CoreData

final class AppDependencies {
    static let shared = AppDependencies()
    
    private let coreDataStack = CoreDataStack.shared
    
    lazy var weekService: WeekService = WeekServiceImpl()
    lazy var balanceCalculator: BalanceCalculator = BalanceCalculatorImpl()
    lazy var currencyFormatter: CurrencyFormatter = CurrencyFormatterImpl(settingsRepo: settingsRepo)
    
    lazy var weekRepo: WeekRepository = WeekRepositoryImpl(
        context: coreDataStack.viewContext,
        weekService: weekService
    )
    
    lazy var envRepo: EnvelopeRepository = EnvelopeRepositoryImpl(
        context: coreDataStack.viewContext
    )
    
    lazy var entryRepo: EntryRepository = EntryRepositoryImpl(
        context: coreDataStack.viewContext
    )
    
    lazy var badgeRepo: BadgeRepository = BadgeRepositoryImpl(
        context: coreDataStack.viewContext
    )
    
    lazy var settingsRepo: SettingRepository = SettingRepositoryImpl(
        context: coreDataStack.viewContext
    )
    
    lazy var setupWeekUC: SetupWeekUseCase = SetupWeekUseCaseImpl(
        weekRepo: weekRepo,
        envRepo: envRepo,
        settings: settingsRepo,
        weekSvc: weekService
    )
    
    lazy var upsertEntryUC: UpsertEntryUseCase = UpsertEntryUseCaseImpl(
        weekRepo: weekRepo,
        envRepo: envRepo,
        entryRepo: entryRepo,
        settings: settingsRepo,
        weekSvc: weekService
    )
    
    lazy var closeWeekUC: CloseWeekUseCase = CloseWeekUseCaseImpl(
        weekRepo: weekRepo,
        envRepo: envRepo,
        badgeRepo: badgeRepo,
        balance: balanceCalculator
    )
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            setupUC: setupWeekUC,
            addUC: upsertEntryUC,
            balance: balanceCalculator,
            formatter: currencyFormatter
        )
    }
    
    func makeSetupViewModel() -> SetupViewModel {
        return SetupViewModel(uc: setupWeekUC)
    }
    
    func makeArchiveViewModel() -> ArchiveViewModel {
        return ArchiveViewModel(
            weekRepo: weekRepo,
            envRepo: envRepo,
            badgeRepo: badgeRepo
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(settings: settingsRepo)
    }
    
    func makeStatisticsViewModel() -> StatisticsViewModel {
        return StatisticsViewModel(
            weekRepo: weekRepo,
            envRepo: envRepo,
            badgeRepo: badgeRepo,
            entryRepo: entryRepo,
            formatter: currencyFormatter
        )
    }
    
    func makeManageEnvelopesViewModel() -> ManageEnvelopesViewModel {
        return ManageEnvelopesViewModel(
            setupUC: setupWeekUC,
            envRepo: envRepo
        )
    }
}

