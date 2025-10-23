// RepositoryProtocols.swift
import Foundation

// MARK: - Scenario/Dialog Repositories
public protocol ScenarioRepository {
    func listAll(minLevel: Int?) async throws -> [ScenarioDTO]
    func loadGraph(scenarioId: UUID) async throws -> DialogGraphDTO
}

public protocol DialogSessionRepository {
    func start(scenarioId: UUID, level: Int) async throws -> SessionTranscriptDTO
    func appendTurn(sessionId: UUID, turn: DialogTurnDTO) async throws
    func finish(sessionId: UUID, achievedGoals: [String], newWordIds: [UUID]) async throws
    func timeline(sessionId: UUID) async throws -> DialogTimelineModel
}

// MARK: - Immersion/Glossary Repositories
public protocol ImmersionRepository {
    func feed(byTopics: [String], limit: Int) async throws -> [ImmersionCardDTO]
    func glossary(forTopic: String) async throws -> [VocabularyDTO]
}

// MARK: - Micro Lessons/Weak Spots Repositories
public protocol MicroLessonRepository {
    func queueForToday() async throws -> [MicroLessonDTO]
    func save(_ lesson: MicroLessonDTO) async throws
    func markDone(_ id: UUID) async throws
}

public protocol WeakSpotRepository {
    func topWeakSpots(limit: Int) async throws -> [WeakSpotDTO]
    func upsert(_ spots: [WeakSpotDTO]) async throws
}

// MARK: - Vocabulary Repository
public protocol VocabularyRepository {
    func add(_ item: VocabularyDTO) async throws -> VocabularyDTO
    func listAll() async throws -> [VocabularyDTO]
    func updateStrength(id: UUID, value: Int) async throws
}

// MARK: - Progress/Charts Repository
public protocol ProgressRepository {
    func usefulDonut(dayKey: Date) async throws -> UsefulDonutModel
    func topicPie(range: ClosedRange<Date>) async throws -> TopicPieModel
    func barSeries(range: ClosedRange<Date>) async throws -> BarSeries
    func weakHeatmap(range: ClosedRange<Date>) async throws -> WeakHeatmapModel
}

// MARK: - Settings/Interests Repositories
public protocol SettingsRepository {
    func load() async throws -> SettingsDTO
    func save(_ s: SettingsDTO) async throws
}

public protocol InterestRepository {
    func list() async throws -> [InterestDTO]
    func update(_ interests: [InterestDTO]) async throws
}
