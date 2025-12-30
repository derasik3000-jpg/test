import Foundation

@MainActor
final class PqJournalViewModel {
    private let weekUC: PqBuildWeekBarsUseCase
    private let dayRepo: PqDayRecordRepo
    
    private(set) var week = WeekBarsData(items: [])
    private(set) var selectedDay: DayDTO?
    
    var onUpdate: (() -> Void)?
    
    init(weekUC: PqBuildWeekBarsUseCase, dayRepo: PqDayRecordRepo) {
        self.weekUC = weekUC
        self.dayRepo = dayRepo
    }
    
    func pqDidBecomeVisible() {
        Task { await pqRefreshWeekState() }
    }
    
    func pqRefreshWeekState(reference: Date = Date()) async {
        do {
            week = try await weekUC.pqPerformWeekBarsBuild(endingAt: reference)
            onUpdate?()
        } catch {
            print("Error reloading week: \(error)")
        }
    }
    
    func openDay(_ date: Date) {
        Task {
            do {
                if let existing = try await dayRepo.pqRetrieveData(date: date) {
                    selectedDay = existing
                } else {
                    selectedDay = try await dayRepo.pqProvideEntry(for: date)
                }
                onUpdate?()
            } catch {
                print("Error opening day: \(error)")
            }
        }
    }
    
    func applyFromDayToToday(_ date: Date) {
        Task {
            do {
                _ = try await dayRepo.pqDuplicateStepsFrom(date: date, to: Date())
                await pqRefreshWeekState()
            } catch {
                print("Error applying ritual: \(error)")
            }
        }
    }
    
    func updateDayRating(date: Date, rating: Int) {
        Task {
            do {
                _ = try await dayRepo.pqModifyRating(date: date, rating: rating)
                await pqRefreshWeekState()
            } catch {
                print("Error updating rating: \(error)")
            }
        }
    }
    
    func updateDayNote(date: Date, note: String?) {
        Task {
            do {
                _ = try await dayRepo.pqModifyNote(date: date, note: note)
            } catch {
                print("Error updating note: \(error)")
            }
        }
    }
}

