import Foundation

protocol PqRitualFlowRepo {
    @MainActor func pqFetchActiveRecords() async throws -> [RitualStepDTO]
    @MainActor func pqFetchAllRecords() async throws -> [RitualStepDTO]
    @MainActor func pqMergeRecord(_ step: RitualStepDTO) async throws
    @MainActor func pqRearrangeOrder(idsInOrder: [UUID]) async throws
    @MainActor func pqSetArchiveState(id: UUID, isArchived: Bool) async throws
}

protocol PqTagDataRepo {
    @MainActor func pqFetchAllRecords() async throws -> [TagDTO]
    @MainActor func pqInsertNew(name: String) async throws -> TagDTO
    @MainActor func pqSetArchiveState(id: UUID, isArchived: Bool) async throws
}

protocol PqConfigRepo {
    @MainActor func pqRetrieveData() async throws -> SettingsDTO
    @MainActor func pqPersistData(_ s: SettingsDTO) async throws
}

protocol PqDayRecordRepo {
    @MainActor func pqProvideEntry(for date: Date) async throws -> DayDTO
    @MainActor func pqRetrieveData(date: Date) async throws -> DayDTO?
    @MainActor func pqModifySleepWindow(date: Date, start: (Int, Int), end: (Int, Int)) async throws -> DayDTO
    @MainActor func pqModifyRating(date: Date, rating: Int) async throws -> DayDTO
    @MainActor func pqModifyNote(date: Date, note: String?) async throws -> DayDTO
    @MainActor func pqAssignTags(date: Date, tagIDs: [UUID]) async throws -> DayDTO
    @MainActor func pqSwitchStepState(date: Date, stepID: UUID, isDone: Bool, timestamp: Date?) async throws -> DayDTO
    @MainActor func pqClearSteps(date: Date) async throws -> DayDTO
    @MainActor func pqDuplicateStepsFrom(date src: Date, to dateDst: Date) async throws -> DayDTO
}

protocol PqMetricsRepo {
    @MainActor func pqCalculateRitualProgress(date: Date) async throws -> (done: Int, total: Int)
    @MainActor func pqEvaluateCalmness(date: Date) async throws -> Bool
    @MainActor func pqCountCalmDays(since: Date) async throws -> Int
    @MainActor func pqBuildWeekSummary(endingAt date: Date) async throws -> [WeekPointDTO]
    @MainActor func pqConstructTimeline(date: Date) async throws -> [StepPoint]
}

protocol PqAchievementRepo {
    @MainActor func pqGrantAchievement(kind: String) async throws
    @MainActor func pqFetchList() async throws -> [String]
}

