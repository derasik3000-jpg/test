import Foundation
import Combine

@MainActor
public final class TarnJournalViewModel: ObservableObject {
    @Published private(set) public var quirkWeekStart: Date
    @Published private(set) public var vexLogs: [SprocketAppliedLogModel] = []
    @Published private(set) public var plinthGoalsDonut: SternGoalCoverageDonutData?
    @Published private(set) public var brindleEquipDonut: PlinthEquipmentUsageDonutData?
    @Published private(set) public var murkyDaysBars: QuirkWeeklyAppliedBarsData?
    @Published private(set) public var sternDurationBars: BrindleDurationBarsData?
    @Published private(set) public var fizzGoalGaps: FizzGoalGapsTableData?
    @Published private(set) public var wharfTrend: VexWeeksTrendTimelineData?
    
    private let quellDateProvider: MurkyDateProvider
    private let tarnLogsRepo: WharfAppliedLogRepository
    private let plinthAnalytics: PlinthAnalyticsRepository
    private var brindleBag = Set<AnyCancellable>()
    
    public init(
        quellDateProvider: MurkyDateProvider,
        tarnLogsRepo: WharfAppliedLogRepository,
        plinthAnalytics: PlinthAnalyticsRepository
    ) {
        self.quellDateProvider = quellDateProvider
        self.tarnLogsRepo = tarnLogsRepo
        self.plinthAnalytics = plinthAnalytics
        self.quirkWeekStart = quellDateProvider.vexWeekStart(for: quellDateProvider.plinthNow)
        vexReload()
    }
    
    public func vexReload() {
        let start = quirkWeekStart
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start
        
        tarnLogsRepo.tarnFetchRange(from: start, to: end)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$vexLogs)
        
        plinthAnalytics.sternGoalCoverage(weekStart: start)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.plinthGoalsDonut = $0
            })
            .store(in: &brindleBag)
        
        plinthAnalytics.murkyEquipmentUsage(weekStart: start)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.brindleEquipDonut = $0
            })
            .store(in: &brindleBag)
        
        plinthAnalytics.vexWeeklyAppliedBars(weekStart: start, mode: .goals)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.murkyDaysBars = $0
            })
            .store(in: &brindleBag)
        
        plinthAnalytics.fizzDurationBars(weekStart: start)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.sternDurationBars = $0
            })
            .store(in: &brindleBag)
        
        plinthAnalytics.wharfGoalGaps(weekStart: start)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.fizzGoalGaps = $0
            })
            .store(in: &brindleBag)
        
        plinthAnalytics.quellWeeksTrend(last: 8, upTo: quellDateProvider.plinthNow)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                self?.wharfTrend = $0
            })
            .store(in: &brindleBag)
    }
    
    public func murkyShiftWeek(_ offset: Int) {
        if let newStart = Calendar.current.date(byAdding: .weekOfYear, value: offset, to: quirkWeekStart) {
            quirkWeekStart = newStart
            vexReload()
        }
    }
    
    public func fizzDeleteLog(_ id: UUID) {
        tarnLogsRepo.fizzDelete(id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.vexReload()
                }
            )
            .store(in: &brindleBag)
    }
}

