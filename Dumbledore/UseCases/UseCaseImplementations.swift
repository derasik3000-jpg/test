// UseCaseImplementations.swift
import Foundation

// MARK: - Start Dialog Use Case
class StartDialogUseCaseImpl: StartDialogUseCase {
    private let sessionRepository: DialogSessionRepository
    
    init(sessionRepository: DialogSessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func execute(scenarioId: UUID, level: Int) async throws -> SessionTranscriptDTO {
        return try await sessionRepository.start(scenarioId: scenarioId, level: level)
    }
}

// MARK: - Handle User Utterance Use Case
class HandleUserUtteranceUseCaseImpl: HandleUserUtteranceUseCase {
    private let sessionRepository: DialogSessionRepository
    private let vocabularyRepository: VocabularyRepository
    
    init(sessionRepository: DialogSessionRepository, vocabularyRepository: VocabularyRepository) {
        self.sessionRepository = sessionRepository
        self.vocabularyRepository = vocabularyRepository
    }
    
    func execute(sessionId: UUID, userText: String) async throws -> (aiReply: String, reachedGoals: [String]) {
        // Simple NLU logic - in a real app, this would be more sophisticated
        let aiReply = generateAIResponse(for: userText)
        let reachedGoals = extractGoals(from: userText)
        
        // Add turn to session
        let turn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: false,
            text: userText,
            marks: []
        )
        
        try await sessionRepository.appendTurn(sessionId: sessionId, turn: turn)
        
        return (aiReply, reachedGoals)
    }
    
    private func generateAIResponse(for userText: String) -> String {
        let responses = [
            "That's interesting! Tell me more about that.",
            "I understand. What would you like to do next?",
            "Great point! Let's continue with our conversation.",
            "I see. How do you feel about that?",
            "Perfect! You're doing really well with this scenario."
        ]
        return responses.randomElement() ?? "I understand. Let's continue."
    }
    
    private func extractGoals(from userText: String) -> [String] {
        // Simple goal extraction - in a real app, this would use more sophisticated NLP
        var goals: [String] = []
        
        if userText.lowercased().contains("order") {
            goals.append("order_item")
        }
        if userText.lowercased().contains("price") || userText.lowercased().contains("cost") {
            goals.append("ask_price")
        }
        if userText.lowercased().contains("no") && userText.lowercased().contains("onion") {
            goals.append("no_onion")
        }
        
        return goals
    }
}

// MARK: - Finish Dialog Use Case
class FinishDialogUseCaseImpl: FinishDialogUseCase {
    private let sessionRepository: DialogSessionRepository
    
    init(sessionRepository: DialogSessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func execute(sessionId: UUID) async throws -> DialogTimelineModel {
        return try await sessionRepository.timeline(sessionId: sessionId)
    }
}

// MARK: - Build Immersion Feed Use Case
class BuildImmersionFeedUseCaseImpl: BuildImmersionFeedUseCase {
    private let immersionRepository: ImmersionRepository
    
    init(immersionRepository: ImmersionRepository) {
        self.immersionRepository = immersionRepository
    }
    
    func execute(topics: [String], limit: Int) async throws -> [ImmersionCardDTO] {
        return try await immersionRepository.feed(byTopics: topics, limit: limit)
    }
}

// MARK: - Generate Micro Lesson Use Case
class GenerateMicroLessonUseCaseImpl: GenerateMicroLessonUseCase {
    private let microLessonRepository: MicroLessonRepository
    private let weakSpotRepository: WeakSpotRepository
    private let vocabularyRepository: VocabularyRepository
    
    init(microLessonRepository: MicroLessonRepository, 
         weakSpotRepository: WeakSpotRepository,
         vocabularyRepository: VocabularyRepository) {
        self.microLessonRepository = microLessonRepository
        self.weakSpotRepository = weakSpotRepository
        self.vocabularyRepository = vocabularyRepository
    }
    
    func execute(source: String) async throws -> MicroLessonDTO {
        let items = try await generateLessonItems(from: source)
        let estimatedSec = items.count * 30 // 30 seconds per item
        
        let lesson = MicroLessonDTO(
            id: UUID(),
            kind: determineLessonKind(from: source),
            items: items,
            estimatedSec: estimatedSec,
            createdFrom: source,
            dayKey: Date()
        )
        
        try await microLessonRepository.save(lesson)
        return lesson
    }
    
    private func generateLessonItems(from source: String) async throws -> [String] {
        switch source {
        case "errors":
            let weakSpots = try await weakSpotRepository.topWeakSpots(limit: 3)
            return weakSpots.map { $0.key }
        case "favorites":
            let vocabulary = try await vocabularyRepository.listAll()
            return vocabulary.filter { $0.strength < 3 }.prefix(4).map { $0.text }
        case "immersion":
            return ["Hello, how are you?", "Nice to meet you", "Have a great day!"]
        default:
            return ["hello", "world", "goodbye"]
        }
    }
    
    private func determineLessonKind(from source: String) -> Int {
        switch source {
        case "errors": return 1 // Pattern exercise
        case "favorites": return 0 // Words practice
        case "immersion": return 2 // Dictation
        default: return 0
        }
    }
}

// MARK: - Complete Micro Lesson Use Case
class CompleteMicroLessonUseCaseImpl: CompleteMicroLessonUseCase {
    private let microLessonRepository: MicroLessonRepository
    private let vocabularyRepository: VocabularyRepository
    
    init(microLessonRepository: MicroLessonRepository, vocabularyRepository: VocabularyRepository) {
        self.microLessonRepository = microLessonRepository
        self.vocabularyRepository = vocabularyRepository
    }
    
    func execute(id: UUID) async throws {
        try await microLessonRepository.markDone(id)
        
        // Update vocabulary strength for completed words
        // This is a simplified version - in a real app, you'd track which words were practiced
        let vocabulary = try await vocabularyRepository.listAll()
        for var item in vocabulary {
            if item.strength < 5 {
                try await vocabularyRepository.updateStrength(id: item.id, value: item.strength + 1)
            }
        }
    }
}

// MARK: - Build Useful Donut Use Case
class BuildUsefulDonutUseCaseImpl: BuildUsefulDonutUseCase {
    private let progressRepository: ProgressRepository
    
    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
    }
    
    func execute(dayKey: Date) async throws -> UsefulDonutModel {
        return try await progressRepository.usefulDonut(dayKey: dayKey)
    }
}

// MARK: - Build Topic Pie Use Case
class BuildTopicPieUseCaseImpl: BuildTopicPieUseCase {
    private let progressRepository: ProgressRepository
    
    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
    }
    
    func execute(range: ClosedRange<Date>) async throws -> TopicPieModel {
        return try await progressRepository.topicPie(range: range)
    }
}

// MARK: - Build Bar Series Use Case
class BuildBarSeriesUseCaseImpl: BuildBarSeriesUseCase {
    private let progressRepository: ProgressRepository
    
    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
    }
    
    func execute(range: ClosedRange<Date>) async throws -> BarSeries {
        return try await progressRepository.barSeries(range: range)
    }
}

// MARK: - Build Weak Heatmap Use Case
class BuildWeakHeatmapUseCaseImpl: BuildWeakHeatmapUseCase {
    private let progressRepository: ProgressRepository
    
    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
    }
    
    func execute(range: ClosedRange<Date>) async throws -> WeakHeatmapModel {
        return try await progressRepository.weakHeatmap(range: range)
    }
}
