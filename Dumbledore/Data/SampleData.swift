// SampleData.swift
import Foundation

struct SampleData {
    static let scenarios: [ScenarioDTO] = [
        ScenarioDTO(
            id: UUID(),
            title: "Restaurant: Ordering Food",
            levelMin: 1,
            topics: ["food", "restaurant"],
            goals: ["order_item", "ask_price", "no_onion"],
            graphRef: "restaurant_order.json",
            createdAt: Date(),
            updatedAt: Date()
        ),
        ScenarioDTO(
            id: UUID(),
            title: "Job Interview",
            levelMin: 2,
            topics: ["work", "career"],
            goals: ["introduce_yourself", "discuss_experience", "ask_questions"],
            graphRef: "job_interview.json",
            createdAt: Date(),
            updatedAt: Date()
        ),
        ScenarioDTO(
            id: UUID(),
            title: "Small Talk",
            levelMin: 1,
            topics: ["social", "general"],
            goals: ["greet", "ask_about_day", "respond_politely"],
            graphRef: "small_talk.json",
            createdAt: Date(),
            updatedAt: Date()
        ),
        ScenarioDTO(
            id: UUID(),
            title: "Hotel Check-in",
            levelMin: 2,
            topics: ["travel", "accommodation"],
            goals: ["provide_reservation", "request_room", "ask_about_amenities"],
            graphRef: "hotel_checkin.json",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    static let immersionCards: [ImmersionCardDTO] = [
        ImmersionCardDTO(
            id: UUID(),
            title: "Tech Startup Pitch",
            topic: "IT",
            phrases: [
                "We're disrupting the market",
                "Our solution scales efficiently",
                "We need seed funding",
                "The market opportunity is huge"
            ],
            glossary: [
                GlossItemDTO(word: "disrupt", meaning: "to change the way something works", example: "Uber disrupted the taxi industry"),
                GlossItemDTO(word: "scale", meaning: "to grow or expand", example: "The company scaled from 10 to 1000 employees"),
                GlossItemDTO(word: "seed funding", meaning: "early investment in a startup", example: "We raised $2M in seed funding")
            ],
            quiz: [
                QuizItemDTO(question: "What does 'disrupt' mean?", options: ["to break", "to change the way something works", "to stop"], correctAnswer: 1)
            ],
            createdAt: Date()
        ),
        ImmersionCardDTO(
            id: UUID(),
            title: "Movie Review Discussion",
            topic: "Movies",
            phrases: [
                "The plot was predictable",
                "The acting was outstanding",
                "I'd give it 4 out of 5 stars",
                "The cinematography was beautiful"
            ],
            glossary: [
                GlossItemDTO(word: "plot", meaning: "the main story", example: "The plot of the movie was very complex"),
                GlossItemDTO(word: "outstanding", meaning: "exceptionally good", example: "Her performance was outstanding"),
                GlossItemDTO(word: "cinematography", meaning: "the art of making movies", example: "The cinematography in this film is stunning")
            ],
            quiz: [
                QuizItemDTO(question: "What does 'outstanding' mean?", options: ["very bad", "exceptionally good", "average"], correctAnswer: 1)
            ],
            createdAt: Date().addingTimeInterval(-3600)
        ),
        ImmersionCardDTO(
            id: UUID(),
            title: "Travel Planning",
            topic: "Travel",
            phrases: [
                "I'm planning a trip to Europe",
                "What's the best time to visit?",
                "I'm looking for budget accommodations",
                "How many days should I spend there?"
            ],
            glossary: [
                GlossItemDTO(word: "accommodations", meaning: "places to stay", example: "We found great accommodations near the beach"),
                GlossItemDTO(word: "budget", meaning: "inexpensive", example: "We're looking for budget-friendly options")
            ],
            quiz: [
                QuizItemDTO(question: "What does 'accommodations' mean?", options: ["food", "places to stay", "transportation"], correctAnswer: 1)
            ],
            createdAt: Date().addingTimeInterval(-7200)
        )
    ]
    
    static let vocabularyItems: [VocabularyDTO] = [
        VocabularyDTO(
            id: UUID(),
            text: "restaurant",
            translation: "ресторан",
            examples: ["I love this restaurant", "Let's go to a restaurant"],
            topicTags: ["food", "restaurant"],
            addedAt: Date(),
            strength: 3
        ),
        VocabularyDTO(
            id: UUID(),
            text: "interview",
            translation: "собеседование",
            examples: ["I have an interview tomorrow", "The interview went well"],
            topicTags: ["work", "career"],
            addedAt: Date().addingTimeInterval(-86400),
            strength: 2
        ),
        VocabularyDTO(
            id: UUID(),
            text: "accommodation",
            translation: "размещение",
            examples: ["We need to find accommodation", "The accommodation was excellent"],
            topicTags: ["travel", "hotel"],
            addedAt: Date().addingTimeInterval(-172800),
            strength: 1
        )
    ]
    
    static let microLessons: [MicroLessonDTO] = [
        MicroLessonDTO(
            id: UUID(),
            kind: 0,
            items: ["hello", "world", "goodbye", "thank you"],
            estimatedSec: 120,
            createdFrom: "errors",
            dayKey: Date()
        ),
        MicroLessonDTO(
            id: UUID(),
            kind: 1,
            items: ["used to", "would", "could", "should"],
            estimatedSec: 180,
            createdFrom: "favorites",
            dayKey: Date()
        ),
        MicroLessonDTO(
            id: UUID(),
            kind: 2,
            items: ["Hello, how are you?", "Nice to meet you", "Have a great day!"],
            estimatedSec: 150,
            createdFrom: "immersion",
            dayKey: Date()
        )
    ]
    
    static let weakSpots: [WeakSpotDTO] = [
        WeakSpotDTO(
            id: UUID(),
            type: 0,
            key: "articles",
            count7d: 5,
            lastSeenAt: Date(),
            autoQueued: true
        ),
        WeakSpotDTO(
            id: UUID(),
            type: 1,
            key: "past_tense",
            count7d: 3,
            lastSeenAt: Date().addingTimeInterval(-3600),
            autoQueued: false
        ),
        WeakSpotDTO(
            id: UUID(),
            type: 2,
            key: "th_sound",
            count7d: 7,
            lastSeenAt: Date().addingTimeInterval(-1800),
            autoQueued: true
        )
    ]
    
    static let interestTopics: [InterestDTO] = [
        InterestDTO(id: UUID(), tag: "IT", enabled: true),
        InterestDTO(id: UUID(), tag: "Movies", enabled: true),
        InterestDTO(id: UUID(), tag: "Travel", enabled: true),
        InterestDTO(id: UUID(), tag: "UX", enabled: false),
        InterestDTO(id: UUID(), tag: "Sports", enabled: false),
        InterestDTO(id: UUID(), tag: "Food", enabled: true)
    ]
}
