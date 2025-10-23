// UseCaseProtocols.swift
import Foundation

// MARK: - Dialog/Voice Use Cases
public protocol StartDialogUseCase {
    func execute(scenarioId: UUID, level: Int) async throws -> SessionTranscriptDTO
}

public protocol HandleUserUtteranceUseCase {
    func execute(sessionId: UUID, userText: String) async throws -> (aiReply: String, reachedGoals: [String])
}

public protocol FinishDialogUseCase {
    func execute(sessionId: UUID) async throws -> DialogTimelineModel
}

// MARK: - Immersion/Micro-lessons Use Cases
public protocol BuildImmersionFeedUseCase {
    func execute(topics: [String], limit: Int) async throws -> [ImmersionCardDTO]
}

public protocol GenerateMicroLessonUseCase {
    func execute(source: String) async throws -> MicroLessonDTO
}

public protocol CompleteMicroLessonUseCase {
    func execute(id: UUID) async throws
}

// MARK: - Charts/Progress Use Cases
public protocol BuildUsefulDonutUseCase {
    func execute(dayKey: Date) async throws -> UsefulDonutModel
}

public protocol BuildTopicPieUseCase {
    func execute(range: ClosedRange<Date>) async throws -> TopicPieModel
}

public protocol BuildBarSeriesUseCase {
    func execute(range: ClosedRange<Date>) async throws -> BarSeries
}

public protocol BuildWeakHeatmapUseCase {
    func execute(range: ClosedRange<Date>) async throws -> WeakHeatmapModel
}
