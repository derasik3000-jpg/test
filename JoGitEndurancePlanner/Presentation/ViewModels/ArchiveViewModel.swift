import Foundation
import Combine
import CoreData

struct CycleStatsSnapshot {
    let totalWeeks: Int
    let averageReduction: Int
    let lastDeloadDate: Date?
    let currentStreak: Int
    let recommendationText: String
    let recommendationColor: String
}

@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published private(set) var trendData: TrendTimelineSnapshot?
    @Published private(set) var recentWeeks: [SpanCycleModel] = []
    @Published private(set) var stats: CycleStatsSnapshot?
    @Published private(set) var completedDates: Set<Date> = []
    @Published var showingNewCycleWizard = false
    
    private let bounceVault: BounceVaultProtocol
    private let metricsVault: MetricsVaultProtocol
    private let clockProvider: ClockProvider
    private var cancellables = Set<AnyCancellable>()
    
    init(bounceVault: BounceVaultProtocol, metricsVault: MetricsVaultProtocol, clockProvider: ClockProvider) {
        self.bounceVault = bounceVault
        self.metricsVault = metricsVault
        self.clockProvider = clockProvider
    }
    
    func loadHistory() {
        loadStatsFromAllWeeks()
    }
    
    private func loadStatsFromAllWeeks() {
        Future<(TrendTimelineSnapshot, Set<Date>), Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "ArchiveVM", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "weekStart", ascending: false)]
            
            do {
                let weeks = try PersistenceCoordinator.shared.context.fetch(request)
                var completedDatesSet = Set<Date>()
                var allMarkers: [TrendMarker] = []
                
                for week in weeks {
                    guard let weekStart = week.weekStart else { continue }
                    
                    let sessionsRequest: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
                    sessionsRequest.predicate = NSPredicate(format: "week == %@", week)
                    let sessions = try? PersistenceCoordinator.shared.context.fetch(sessionsRequest)
                    
                    let completed = sessions?.filter { $0.isDone } ?? []
                    
                    for session in completed {
                        let dayDate = Calendar.current.date(byAdding: .day, value: Int(session.dayIndex), to: weekStart)
                        if let dayDate = dayDate {
                            let dayStart = Calendar.current.startOfDay(for: dayDate)
                            completedDatesSet.insert(dayStart)
                        }
                    }
                    
                    let totalPlan = completed.reduce(0) { $0 + Int($1.planMinutes) }
                    let totalReduced = completed.reduce(0) { $0 + Int($1.reducedMinutes) }
                    
                    let actualRate = totalPlan > 0 ? Int(round((1.0 - Double(totalReduced) / Double(totalPlan)) * 100.0)) : Int(week.targetPercent)
                    let targetRate = Int(week.targetPercent)
                    
                    let verdict: String
                    let diff = abs(actualRate - targetRate)
                    if diff <= 3 {
                        verdict = "On Target"
                    } else if actualRate < targetRate - 3 {
                        verdict = "Shortfall"
                    } else {
                        verdict = "Over"
                    }
                    
                    allMarkers.append(TrendMarker(
                        cycleKickoff: weekStart,
                        targetRate: targetRate,
                        achievedRate: actualRate,
                        verdictLabel: verdict
                    ))
                }
                
                let timeline = TrendTimelineSnapshot(markers: allMarkers)
                promise(.success((timeline, completedDatesSet)))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] result in
                guard let self = self else { return }
                let (timeline, dates) = result
                self.trendData = timeline
                self.completedDates = dates
                self.calculateStats(from: timeline)
            }
        )
        .store(in: &cancellables)
    }
    
    private func calculateStats(from timeline: TrendTimelineSnapshot?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: clockProvider.currentMoment)
        
        guard let timeline = timeline, !timeline.markers.isEmpty else {
            stats = CycleStatsSnapshot(
                totalWeeks: 0,
                averageReduction: 0,
                lastDeloadDate: nil,
                currentStreak: 0,
                recommendationText: "Start your first deload week",
                recommendationColor: "#0EBAEF"
            )
            return
        }
        
        let total = timeline.markers.count
        let avgReduction = timeline.markers.reduce(0) { $0 + $1.achievedRate } / total
        let lastDate = timeline.markers.last?.cycleKickoff
        
        var streak = 0
        
        // Находим последний день с выполненными сессиями (не позже сегодня)
        let pastCompletedDates = completedDates.filter { $0 <= today }
        guard let lastCompletedDate = pastCompletedDates.max() else {
            // Нет выполненных дней в прошлом
            stats = CycleStatsSnapshot(
                totalWeeks: total,
                averageReduction: avgReduction,
                lastDeloadDate: lastDate,
                currentStreak: 0,
                recommendationText: "Start your streak",
                recommendationColor: "#0EBAEF"
            )
            return
        }
        
        // Начинаем считать streak от последнего выполненного дня назад
        var checkDate = lastCompletedDate
        
        // Идем назад, пока есть выполненные дни подряд
        while completedDates.contains(checkDate) {
            streak += 1
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) {
                checkDate = calendar.startOfDay(for: previousDay)
            } else {
                break
            }
        }
        
        let (recText, recColor): (String, String)
        if streak > 0 {
            if streak >= 7 {
                recText = "Great streak!"
                recColor = "#2EC27E"
            } else if streak >= 3 {
                recText = "Keep it up"
                recColor = "#0EBAEF"
            } else {
                recText = "Building streak"
                recColor = "#F2C94C"
            }
        } else {
            recText = "Start your streak"
            recColor = "#0EBAEF"
        }
        
        stats = CycleStatsSnapshot(
            totalWeeks: total,
            averageReduction: avgReduction,
            lastDeloadDate: lastDate,
            currentStreak: streak,
            recommendationText: recText,
            recommendationColor: recColor
        )
    }
    
    func createNewCycle(blueprint: TaperBlueprint, startDate: Date? = nil) {
        let kickoff = startDate ?? bounceVault.anchorForCycle(at: clockProvider.currentMoment)
        
        bounceVault.storePlan(blueprint)
            .flatMap { [weak self] plan -> AnyPublisher<SpanCycleModel, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "ArchiveVM", code: -1)).eraseToAnyPublisher()
                }
                return self.bounceVault.retrieveOrBuildCycle(kickoff: kickoff, blueprint: plan)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.showingNewCycleWizard = false
                    self?.loadHistory()
                }
            )
            .store(in: &cancellables)
    }
}

