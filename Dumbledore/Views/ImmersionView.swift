// ImmersionView.swift
import SwiftUI

struct ImmersionView: View {
    @StateObject private var viewModel = ImmersionViewModel()
    @State private var selectedTopic: String?
    @State private var showingCardDetail: ImmersionCardDTO?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Topic Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .iWingPaddingSmall) {
                        ForEach(viewModel.availableTopics, id: \.self) { topic in
                            Button(action: {
                                HapticEngine.play(.light)
                                selectedTopic = selectedTopic == topic ? nil : topic
                                viewModel.filterByTopic(selectedTopic)
                            }) {
                                Text(topic)
                            }
                            .iWingChip(isSelected: selectedTopic == topic)
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                }
                .padding(.vertical, .iWingPaddingSmall)
                .background(Color.iWingSurface)
                
                // Cards Feed
                ScrollView {
                    LazyVStack(spacing: .iWingPadding) {
                        ForEach(viewModel.filteredCards) { card in
                            ImmersionCardView(card: card) {
                                showingCardDetail = card
                            }
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                    .padding(.vertical, .iWingPadding)
                }
            }
            .fillGradientBackground()
            .navigationTitle("Immersion")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await viewModel.loadCards()
                }
            }
        }
        .sheet(item: $showingCardDetail) { card in
            ImmersionCardDetailView(card: card)
        }
    }
}

struct ImmersionCardView: View {
    let card: ImmersionCardDTO
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                // Header
                HStack {
                    Text(card.topic.uppercased())
                        .font(.iWingSmall)
                        .iWingChip()
                    
                    Spacer()
                    
                    Text(timeAgo(from: card.createdAt))
                        .font(.iWingSmall)
                        .foregroundColor(.iWingTextMuted)
                }
                
                // Title
                Text(card.title)
                    .font(.iWingHeadline)
                    .foregroundColor(.iWingTextPrimary)
                    .multilineTextAlignment(.leading)
                
                // Key Phrases
                VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                    ForEach(card.phrases.prefix(3), id: \.self) { phrase in
                        HStack {
                            Text("•")
                                .foregroundColor(.iWingAccent)
                            Text(phrase)
                                .font(.iWingBody)
                                .foregroundColor(.iWingTextPrimary)
                            Spacer()
                        }
                    }
                }
                
                // Action Buttons
                HStack(spacing: .iWingPaddingSmall) {
                    Button(action: {
                        HapticEngine.play(.light)
                        onTap()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.fill")
                            Text("View")
                        }
                        .font(.iWingCaption)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(IWingAccentButtonStyle())
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .iWingCard()
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ImmersionCardDetailView: View {
    let card: ImmersionCardDTO
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhrase: String?
    @State private var showingQuiz = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .iWingPadding) {
                    // Header
                    VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                        Text(card.topic.uppercased())
                            .font(.iWingSmall)
                            .iWingChip()
                        
                        Text(card.title)
                            .font(.iWingTitle)
                            .foregroundColor(.iWingTextPrimary)
                    }
                    
                    // Key Phrases
                    VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                        Text("Key Phrases")
                            .font(.iWingHeadline)
                            .foregroundColor(.iWingTextPrimary)
                        
                        ForEach(card.phrases, id: \.self) { phrase in
                            PhraseCardView(phrase: phrase, isSelected: selectedPhrase == phrase) {
                                HapticEngine.play(.light)
                                selectedPhrase = selectedPhrase == phrase ? nil : phrase
                            }
                        }
                    }
                    
                    // Glossary
                    if !card.glossary.isEmpty {
                        VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                            Text("Glossary")
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                            
                            ForEach(card.glossary, id: \.word) { item in
                                GlossaryItemView(item: item)
                            }
                        }
                    }
                    
                    // Quiz Section
                    if !card.quiz.isEmpty {
                        VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                            Text("Quick Quiz")
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                            
                            Button(action: {
                                HapticEngine.play(.light)
                                showingQuiz = true
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("Start Quiz")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                            }
                            .buttonStyle(IWingAccentButtonStyle())
                            .iWingCard()
                        }
                    }
                }
                .padding()
            }
            .fillGradientBackground()
            .navigationTitle("Card Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingQuiz) {
            QuizView(questions: card.quiz)
        }
    }
}

struct PhraseCardView: View {
    let phrase: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(phrase)
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Selected")
                            .font(.iWingSmall)
                            .foregroundColor(.iWingSuccess)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.iWingSuccess)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.iWingAccent.opacity(0.1) : Color.iWingSurface)
            .cornerRadius(.iWingCornerRadiusSmall)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GlossaryItemView: View {
    let item: GlossItemDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.word)
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextPrimary)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(item.meaning)
                .font(.iWingCaption)
                .foregroundColor(.iWingTextMuted)
            
            Text("\"\(item.example)\"")
                .font(.iWingCaption)
                .foregroundColor(.iWingTextMuted)
                .italic()
        }
        .padding()
        .iWingCard()
    }
}

struct QuizView: View {
    let questions: [QuizItemDTO]
    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showingResult = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.iWingSurface.ignoresSafeArea()
                
                VStack(spacing: .iWingPadding) {
                    if currentQuestion < questions.count {
                        let question = questions[currentQuestion]
                        
                        VStack(alignment: .leading, spacing: .iWingPadding) {
                            // Progress
                            ProgressView(value: Double(currentQuestion), total: Double(questions.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: .iWingAccent))
                            
                            // Question
                            Text(question.question)
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                                .multilineTextAlignment(.leading)
                            
                            // Options
                            VStack(spacing: .iWingPaddingSmall) {
                                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {
                                        HapticEngine.play(.light)
                                        selectedAnswer = index
                                    }) {
                                        HStack {
                                            Text(option)
                                                .font(.iWingBody)
                                                .foregroundColor(.iWingTextPrimary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if selectedAnswer == index {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.iWingAccent)
                                            }
                                        }
                                        .padding()
                                        .background(selectedAnswer == index ? Color.iWingAccent.opacity(0.1) : Color.white)
                                        .cornerRadius(.iWingCornerRadiusSmall)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            Spacer()
                            
                            // Next Button
                            Button(action: {
                                HapticEngine.play(.light)
                                if selectedAnswer == question.correctAnswer {
                                    score += 1
                                    HapticEngine.play(.success)
                                }
                                nextQuestion()
                            }) {
                                Text(currentQuestion == questions.count - 1 ? "Finish" : "Next")
                                    .font(.iWingBody)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(IWingAccentButtonStyle())
                            .disabled(selectedAnswer == nil)
                        }
                        .padding()
                    } else {
                        // Results
                        VStack(spacing: .iWingPadding) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.iWingSuccess)
                            
                            Text("Quiz Complete!")
                                .font(.iWingTitle)
                                .foregroundColor(.iWingTextPrimary)
                            
                            Text("You scored \(score) out of \(questions.count)")
                                .font(.iWingBody)
                                .foregroundColor(.iWingTextMuted)
                            
                            Button(action: {
                                HapticEngine.play(.success)
                                dismiss()
                            }) {
                                Text("Done")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(IWingAccentButtonStyle())
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            selectedAnswer = nil
        } else {
            // Move to results
            currentQuestion = questions.count
        }
    }
}

// MARK: - ViewModel
@MainActor
class ImmersionViewModel: ObservableObject {
    @Published var availableTopics = ["All", "IT", "Movies", "Travel", "UX", "Sports", "Food"]
    @Published var allCards: [ImmersionCardDTO] = []
    @Published var filteredCards: [ImmersionCardDTO] = []
    
    private let immersionRepository: ImmersionRepository
    
    init() {
        self.immersionRepository = DIContainer.shared.immersionRepository
    }
    
    func loadCards() async {
        do {
            allCards = try await immersionRepository.feed(byTopics: [], limit: 20)
            filteredCards = allCards
        } catch {
            print("Error loading immersion cards: \(error)")
        }
    }
    
    func filterByTopic(_ topic: String?) {
        guard let topic = topic, topic != "All" else {
            filteredCards = allCards
            return
        }
        
        filteredCards = allCards.filter { $0.topic == topic }
    }
}

#Preview {
    ImmersionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
