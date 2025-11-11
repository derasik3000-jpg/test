import Foundation

struct QuizblinkPrompt: Identifiable {
    let id = UUID()
    let questionzText: String
    let optionAlpha: String
    let optionBravo: String
    let deckzType: DeckziType
}

enum DeckziType: String, CaseIterable {
    case eitherOr = "Either/Or"
    case situatzions = "Situations"
}

extension QuizblinkPrompt {
    static let eitherOrDeckz: [QuizblinkPrompt] = [
        QuizblinkPrompt(questionzText: "What's your go-to?", optionAlpha: "☕ Coffee", optionBravo: "🍵 Matcha", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Where would you escape?", optionAlpha: "⛰️ Mountains", optionBravo: "🌊 Ocean", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Your evening choice?", optionAlpha: "🎬 Movie", optionBravo: "📺 Series", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "When do you thrive?", optionAlpha: "🌅 Early Morning", optionBravo: "🌙 Late Night", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Pick your companion!", optionAlpha: "🐱 Cats", optionBravo: "🐶 Dogs", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Dinner time!", optionAlpha: "🍕 Pizza", optionBravo: "🍣 Sushi", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Travel style?", optionAlpha: "🚆 Train", optionBravo: "✈️ Plane", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Party vibe?", optionAlpha: "💃 Dancing", optionBravo: "🎤 Karaoke", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "What energizes you?", optionAlpha: "🏃 Exercise", optionBravo: "📚 Reading", deckzType: .eitherOr),
        QuizblinkPrompt(questionzText: "Sweet treat?", optionAlpha: "🍰 Cake", optionBravo: "🍦 Ice Cream", deckzType: .eitherOr)
    ]
    
    static let situationzDeckz: [QuizblinkPrompt] = [
        QuizblinkPrompt(questionzText: "Surprise vacation!", optionAlpha: "🇪🇺 Europe", optionBravo: "🌏 Asia", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Tonight's plan?", optionAlpha: "🎬 Cinema", optionBravo: "🎲 Board Games", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Gift for a friend?", optionAlpha: "🎟️ Experience", optionBravo: "📦 Physical Item", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Weekend approach?", optionAlpha: "🎲 Spontaneous", optionBravo: "📋 Planned", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Learn something new?", optionAlpha: "🎸 Musical Skill", optionBravo: "💻 Tech Skill", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Celebrate success?", optionAlpha: "🎉 Big Party", optionBravo: "🍽️ Intimate Dinner", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Day off plans?", optionAlpha: "🏙️ City Adventure", optionBravo: "🏡 Stay Home", deckzType: .situatzions),
        QuizblinkPrompt(questionzText: "Creative outlet?", optionAlpha: "✍️ Writing", optionBravo: "🎨 Visual Arts", deckzType: .situatzions)
    ]
}

