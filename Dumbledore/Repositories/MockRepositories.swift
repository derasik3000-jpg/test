// MockRepositories.swift
import Foundation

// MARK: - Mock Scenario Repository
class MockScenarioRepository: ScenarioRepository {
    func listAll(minLevel: Int?) async throws -> [ScenarioDTO] {
        return SampleData.scenarios.filter { scenario in
            minLevel == nil || scenario.levelMin >= minLevel!
        }
    }
    
    func loadGraph(scenarioId: UUID) async throws -> DialogGraphDTO {
        // Mock dialog graph
        let nodes = [
            DialogNodeDTO(
                id: UUID(),
                type: 0, // AI utterance
                levelVariant: 1,
                payload: "Hello! Welcome to our restaurant. How can I help you today?",
                expectedIntents: [],
                transitions: ["greeting": UUID()],
                isStart: true,
                isTerminal: false
            ),
            DialogNodeDTO(
                id: UUID(),
                type: 1, // User intent
                levelVariant: 1,
                payload: "I'd like to order food",
                expectedIntents: ["order", "food"],
                transitions: ["order": UUID()],
                isStart: false,
                isTerminal: false
            )
        ]
        return DialogGraphDTO(nodes: nodes)
    }
}

// MARK: - Mock Dialog Session Repository
class MockDialogSessionRepository: DialogSessionRepository {
    private var sessions: [UUID: SessionTranscriptDTO] = [:]
    
    func start(scenarioId: UUID, level: Int) async throws -> SessionTranscriptDTO {
        let session = SessionTranscriptDTO(
            id: UUID(),
            scenarioId: scenarioId,
            startedAt: Date(),
            endedAt: nil,
            levelAtStart: level,
            achievedGoals: [],
            turns: [],
            newWords: [],
            keptTranscripts: true
        )
        sessions[session.id] = session
        return session
    }
    
    func appendTurn(sessionId: UUID, turn: DialogTurnDTO) async throws {
        if var session = sessions[sessionId] {
            var turns = session.turns
            turns.append(turn)
            session = SessionTranscriptDTO(
                id: session.id,
                scenarioId: session.scenarioId,
                startedAt: session.startedAt,
                endedAt: session.endedAt,
                levelAtStart: session.levelAtStart,
                achievedGoals: session.achievedGoals,
                turns: turns,
                newWords: session.newWords,
                keptTranscripts: session.keptTranscripts
            )
            sessions[sessionId] = session
        }
    }
    
    func finish(sessionId: UUID, achievedGoals: [String], newWordIds: [UUID]) async throws {
        if var session = sessions[sessionId] {
            session = SessionTranscriptDTO(
                id: session.id,
                scenarioId: session.scenarioId,
                startedAt: session.startedAt,
                endedAt: Date(),
                levelAtStart: session.levelAtStart,
                achievedGoals: achievedGoals,
                turns: session.turns,
                newWords: newWordIds,
                keptTranscripts: session.keptTranscripts
            )
            sessions[sessionId] = session
        }
    }
    
    func timeline(sessionId: UUID) async throws -> DialogTimelineModel {
        guard let session = sessions[sessionId] else {
            throw RepositoryError.sessionNotFound
        }
        
        let turns = session.turns.map { turn in
            DialogTurn(
                ts: turn.ts,
                speaker: turn.speakerIsAI ? .ai : .user,
                text: turn.text,
                marks: turn.marks.map { mark in
                    TurnMark(kind: .goalHit, payload: mark)
                }
            )
        }
        
        return DialogTimelineModel(
            scenarioTitle: "Sample Scenario",
            turns: turns
        )
    }
}

// MARK: - Mock Immersion Repository
class MockImmersionRepository: ImmersionRepository {
    func feed(byTopics: [String], limit: Int) async throws -> [ImmersionCardDTO] {
        let filteredCards = SampleData.immersionCards.filter { card in
            byTopics.isEmpty || byTopics.contains(card.topic)
        }
        return Array(filteredCards.prefix(limit))
    }
    
    func glossary(forTopic: String) async throws -> [VocabularyDTO] {
        return SampleData.vocabularyItems.filter { item in
            item.topicTags.contains(forTopic)
        }
    }
}

// MARK: - Mock Micro Lesson Repository
class MockMicroLessonRepository: MicroLessonRepository {
    private var lessons: [MicroLessonDTO] = SampleData.microLessons
    
    func queueForToday() async throws -> [MicroLessonDTO] {
        return lessons.filter { lesson in
            Calendar.current.isDate(lesson.dayKey, inSameDayAs: Date())
        }
    }
    
    func save(_ lesson: MicroLessonDTO) async throws {
        lessons.append(lesson)
    }
    
    func markDone(_ id: UUID) async throws {
        lessons.removeAll { $0.id == id }
    }
}

// MARK: - Mock Weak Spot Repository
class MockWeakSpotRepository: WeakSpotRepository {
    private var spots: [WeakSpotDTO] = SampleData.weakSpots
    
    func topWeakSpots(limit: Int) async throws -> [WeakSpotDTO] {
        return Array(spots.sorted { $0.count7d > $1.count7d }.prefix(limit))
    }
    
    func upsert(_ newSpots: [WeakSpotDTO]) async throws {
        for newSpot in newSpots {
            if let index = spots.firstIndex(where: { $0.id == newSpot.id }) {
                spots[index] = newSpot
            } else {
                spots.append(newSpot)
            }
        }
    }
}

// MARK: - Mock Vocabulary Repository
class MockVocabularyRepository: VocabularyRepository {
    private var items: [VocabularyDTO] = SampleData.vocabularyItems
    
    func add(_ item: VocabularyDTO) async throws -> VocabularyDTO {
        let newItem = VocabularyDTO(
            id: UUID(),
            text: item.text,
            translation: item.translation,
            examples: item.examples,
            topicTags: item.topicTags,
            addedAt: Date(),
            strength: 0
        )
        items.append(newItem)
        return newItem
    }
    
    func listAll() async throws -> [VocabularyDTO] {
        return items
    }
    
    func updateStrength(id: UUID, value: Int) async throws {
        if let index = items.firstIndex(where: { $0.id == id }) {
            var item = items[index]
            item = VocabularyDTO(
                id: item.id,
                text: item.text,
                translation: item.translation,
                examples: item.examples,
                topicTags: item.topicTags,
                addedAt: item.addedAt,
                strength: value
            )
            items[index] = item
        }
    }
}

// MARK: - Mock Progress Repository
class MockProgressRepository: ProgressRepository {
    func usefulDonut(dayKey: Date) async throws -> UsefulDonutModel {
        return UsefulDonutModel(dayKey: dayKey, usefulMinutes: 15, dailyGoalMinutes: 20)
    }
    
    func topicPie(range: ClosedRange<Date>) async throws -> TopicPieModel {
        return TopicPieModel(
            range: range,
            totalMinutes: 120,
            slices: [
                TopicSlice(topicTag: "IT", minutes: 45, share: 0.375),
                TopicSlice(topicTag: "Movies", minutes: 30, share: 0.25),
                TopicSlice(topicTag: "Travel", minutes: 25, share: 0.208),
                TopicSlice(topicTag: "UX", minutes: 20, share: 0.167)
            ]
        )
    }
    
    func barSeries(range: ClosedRange<Date>) async throws -> BarSeries {
        let days = Int(range.upperBound.timeIntervalSince(range.lowerBound) / 86400)
        var bars: [DayBar] = []
        
        for i in 0..<days {
            let date = range.lowerBound.addingDays(i)
            let minutes = Int.random(in: 5...25)
            bars.append(DayBar(
                dayKey: date,
                minutes: minutes,
                reachedGoal: minutes >= 20
            ))
        }
        
        return BarSeries(bars: bars)
    }
    
    func weakHeatmap(range: ClosedRange<Date>) async throws -> WeakHeatmapModel {
        let days = Int(range.upperBound.timeIntervalSince(range.lowerBound) / 86400)
        var cells: [HeatCell] = []
        
        for i in 0..<days {
            let date = range.lowerBound.addingDays(i)
            let intensity = Double.random(in: 0...1)
            cells.append(HeatCell(
                dayKey: date,
                type: .lexis,
                intensity: intensity
            ))
        }
        
        return WeakHeatmapModel(cells: cells)
    }
}

// MARK: - Mock Settings Repository
class MockSettingsRepository: SettingsRepository {
    private var settings = SettingsDTO(
        level: 2,
        ttsRate: 1.0,
        autoHints: true,
        storeTranscripts: true,
        quietHours: ["22:00-08:00"],
        dailyPromptLimit: 3,
        rolloverHour: 0
    )
    
    func load() async throws -> SettingsDTO {
        return settings
    }
    
    func save(_ newSettings: SettingsDTO) async throws {
        settings = newSettings
    }
}

// MARK: - Mock Interest Repository
class MockInterestRepository: InterestRepository {
    private var interests: [InterestDTO] = SampleData.interestTopics
    
    func list() async throws -> [InterestDTO] {
        return interests
    }
    
    func update(_ newInterests: [InterestDTO]) async throws {
        interests = newInterests
    }
}

// MARK: - Repository Error
enum RepositoryError: Error {
    case sessionNotFound
    case itemNotFound
    case invalidData
}
