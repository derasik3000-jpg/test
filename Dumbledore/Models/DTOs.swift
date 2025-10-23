// DTOs.swift
import Foundation

// MARK: - Scenario DTOs
public struct ScenarioDTO: Identifiable {
    public let id: UUID
    public let title: String
    public let levelMin: Int
    public let topics: [String]
    public let goals: [String]
    public let graphRef: String
    public let createdAt: Date
    public let updatedAt: Date
}

public struct DialogGraphDTO {
    public let nodes: [DialogNodeDTO]
}

public struct DialogNodeDTO: Identifiable {
    public let id: UUID
    public let type: Int
    public let levelVariant: Int
    public let payload: String
    public let expectedIntents: [String]
    public let transitions: [String: UUID]
    public let isStart: Bool
    public let isTerminal: Bool
}

// MARK: - Session DTOs
public struct SessionTranscriptDTO: Identifiable {
    public let id: UUID
    public let scenarioId: UUID
    public let startedAt: Date
    public let endedAt: Date?
    public let levelAtStart: Int
    public let achievedGoals: [String]
    public let turns: [DialogTurnDTO]
    public let newWords: [UUID]
    public let keptTranscripts: Bool
}

public struct DialogTurnDTO: Identifiable {
    public let id: UUID
    public let ts: Date
    public let speakerIsAI: Bool
    public let text: String
    public let marks: [String]
}

// MARK: - Immersion DTOs
public struct ImmersionCardDTO: Identifiable {
    public let id: UUID
    public let title: String
    public let topic: String
    public let phrases: [String]
    public let glossary: [GlossItemDTO]
    public let quiz: [QuizItemDTO]
    public let createdAt: Date
}

public struct GlossItemDTO: Codable {
    public let word: String
    public let meaning: String
    public let example: String
}

public struct QuizItemDTO: Codable {
    public let question: String
    public let options: [String]
    public let correctAnswer: Int
}

// MARK: - Vocabulary DTOs
public struct VocabularyDTO: Identifiable {
    public let id: UUID
    public let text: String
    public let translation: String
    public let examples: [String]
    public let topicTags: [String]
    public let addedAt: Date
    public var strength: Int
}

// MARK: - Micro Lesson DTOs
public struct MicroLessonDTO: Identifiable {
    public let id: UUID
    public let kind: Int
    public let items: [String]
    public let estimatedSec: Int
    public let createdFrom: String
    public let dayKey: Date
}

// MARK: - Weak Spot DTOs
public struct WeakSpotDTO: Identifiable {
    public let id: UUID
    public let type: Int
    public let key: String
    public var count7d: Int
    public var lastSeenAt: Date
    public var autoQueued: Bool
}

// MARK: - Settings DTOs
public struct SettingsDTO {
    public var level: Int
    public var ttsRate: Double
    public var autoHints: Bool
    public var storeTranscripts: Bool
    public var quietHours: [String]
    public var dailyPromptLimit: Int
    public var rolloverHour: Int
}

public struct InterestDTO: Identifiable {
    public let id: UUID
    public var tag: String
    public var enabled: Bool
}
