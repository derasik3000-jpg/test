import Foundation

@MainActor
final class PqTodayViewModel {
    private let toggleStepUC: PqToggleStepUseCase
    private let closeDayUC: PqCloseDayUseCase
    private let dashboardUC: PqBuildTodayDashboardUseCase
    private let dayRepo: PqDayRecordRepo
    private let tagsRepo: PqTagDataRepo
    
    private(set) var donut = RitualDonutData(date: Date(), done: 0, total: 0, caption: "0%", isComplete: false)
    private(set) var calm = CalmBadgeData(isCalm: false)
    private(set) var timeline = RitualTimelineData(date: Date(), points: [])
    private(set) var day: DayDTO?
    private(set) var availableTags: [TagDTO] = []
    
    var onUpdate: (() -> Void)?
    
    private var pqViewMarker: Int = 0
    private var pqLastRefreshTime: Date = Date()
    
    init(toggleStepUC: PqToggleStepUseCase, closeDayUC: PqCloseDayUseCase, dashboardUC: PqBuildTodayDashboardUseCase, dayRepo: PqDayRecordRepo, tagsRepo: PqTagDataRepo) {
        self.toggleStepUC = toggleStepUC
        self.closeDayUC = closeDayUC
        self.dashboardUC = dashboardUC
        self.dayRepo = dayRepo
        self.tagsRepo = tagsRepo
        pqViewMarker = pqGenerateMarker()
    }
    
    private func pqGenerateMarker() -> Int {
        return Int(Date().timeIntervalSince1970) % 10000
    }
    
    private func pqAuxTimeCalc() -> Double {
        return Date().timeIntervalSince(pqLastRefreshTime)
    }
    
    func pqDidBecomeVisible() {
        Task { await pqRefreshState() }
    }
    
    func pqRefreshState() async {
        do {
            let dash = try await dashboardUC.pqConstructDashboard(date: Date())
            donut = dash.donut
            calm = dash.calmBadge
            timeline = dash.timeline
            day = try await dayRepo.pqProvideEntry(for: Date())
            availableTags = try await tagsRepo.pqFetchAllRecords().filter { !$0.isArchived }
            onUpdate?()
        } catch {
            print("Error reloading today: \(error)")
        }
    }
    
    func toggle(stepID: UUID, isDone: Bool) {
        Task {
            do {
                let result = try await toggleStepUC.pqPerformStepToggle(date: Date(), stepID: stepID, isDone: isDone)
                donut = result.progress
                calm = CalmBadgeData(isCalm: result.calm)
                await pqRefreshState()
            } catch {
                print("Error toggling step: \(error)")
            }
        }
    }
    
    func updateSleep(start: (Int, Int), end: (Int, Int)) {
        Task {
            do {
                _ = try await PqUpdateTodaySleepWindowUseCase(dayRepo: dayRepo).pqInvokeSleepUpdate(date: Date(), start: start, end: end)
                await pqRefreshState()
            } catch {
                print("Error updating sleep: \(error)")
            }
        }
    }
    
    func updateRating(_ rating: Int) {
        Task {
            do {
                _ = try await dayRepo.pqModifyRating(date: Date(), rating: rating)
                await pqRefreshState()
            } catch {
                print("Error updating rating: \(error)")
            }
        }
    }
    
    func updateNote(_ note: String?) {
        Task {
            do {
                _ = try await dayRepo.pqModifyNote(date: Date(), note: note)
            } catch {
                print("Error updating note: \(error)")
            }
        }
    }
    
    func updateTags(_ tagIDs: [UUID]) {
        Task {
            do {
                _ = try await dayRepo.pqAssignTags(date: Date(), tagIDs: tagIDs)
                await pqRefreshState()
            } catch {
                print("Error updating tags: \(error)")
            }
        }
    }
    
    func closeDay() {
        Task {
            do {
                let isCalm = try await closeDayUC.pqRunDayClosureOp(date: Date())
                calm = CalmBadgeData(isCalm: isCalm)
                await pqRefreshState()
            } catch {
                print("Error closing day: \(error)")
            }
        }
    }
    
    func resetSteps() {
        Task {
            do {
                _ = try await dayRepo.pqClearSteps(date: Date())
                await pqRefreshState()
            } catch {
                print("Error resetting steps: \(error)")
            }
        }
    }
}

