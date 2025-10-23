// MicroLessonsView.swift
import SwiftUI

struct MicroLessonsView: View {
    @StateObject private var viewModel = MicroLessonsViewModel()
    @State private var showingLesson: MicroLessonDTO?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Stats
                VStack(spacing: .iWingPaddingSmall) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(viewModel.completedToday)")
                                .font(.iWingTitle)
                                .foregroundColor(.iWingTextPrimary)
                            Text("Completed Today")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(viewModel.queueCount)")
                                .font(.iWingTitle)
                                .foregroundColor(.iWingAccent)
                            Text("In Queue")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                    .padding(.vertical, .iWingPaddingSmall)
                    .background(Color.iWingSurface)
                }
                
                // Queue List
                if viewModel.queueLessons.isEmpty {
                    EmptyQueueView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: .iWingPaddingSmall) {
                            ForEach(viewModel.queueLessons) { lesson in
                                MicroLessonQueueCardView(lesson: lesson) {
                                    showingLesson = lesson
                                }
                            }
                        }
                        .padding(.horizontal, .iWingPadding)
                        .padding(.vertical, .iWingPadding)
                    }
                }
            }
            .fillGradientBackground()
            .navigationTitle("Micro-lessons")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettings = true
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadQueue()
                }
            }
        }
        .sheet(item: $showingLesson) { lesson in
            MicroLessonSessionView(lesson: lesson) {
                Task {
                    await viewModel.completeLesson(lesson.id)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            MicroLessonSettingsView()
        }
    }
}

struct EmptyQueueView: View {
    var body: some View {
        VStack(spacing: .iWingPadding) {
            Image(systemName: "clock")
                .font(.system(size: 48))
                .foregroundColor(.iWingTextMuted)
            
            Text("No Micro-lessons Available")
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
            
            Text("Complete more dialogs and immersion content to generate personalized micro-lessons")
                .font(.iWingBody)
                .foregroundColor(.iWingTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .iWingPaddingLarge)
            
            Button(action: {
                HapticEngine.play(.light)
                // Would navigate to immersion tab
            }) {
                Text("Browse Immersion")
            }
            .buttonStyle(IWingAccentButtonStyle())
        }
        .padding(.iWingPaddingLarge)
    }
}

struct MicroLessonQueueCardView: View {
    let lesson: MicroLessonDTO
    let onStart: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lessonTitle(for: lesson.kind))
                    .font(.iWingHeadline)
                    .foregroundColor(.iWingTextPrimary)
                
                Text(lessonDescription(for: lesson.kind))
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextMuted)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.iWingSmall)
                    Text("~\(lesson.estimatedSec / 60) min")
                        .font(.iWingSmall)
                        .foregroundColor(.iWingTextMuted)
                    
                    Spacer()
                    
                    Text(lesson.createdFrom.capitalized)
                        .font(.iWingSmall)
                        .iWingChip()
                }
            }
            
            Spacer()
            
            Button(action: {
                HapticEngine.play(.light)
                onStart()
            }) {
                Text("Start")
            }
            .buttonStyle(IWingAccentButtonStyle())
        }
        .padding()
        .iWingCard()
    }
    
    private func lessonTitle(for kind: Int) -> String {
        switch kind {
        case 0: return "Words Practice"
        case 1: return "Pattern Exercise"
        case 2: return "Mini Dictation"
        default: return "Micro Lesson"
        }
    }
    
    private func lessonDescription(for kind: Int) -> String {
        switch kind {
        case 0: return "Practice vocabulary and pronunciation"
        case 1: return "Learn grammar patterns and structures"
        case 2: return "Improve listening and writing skills"
        default: return "Quick language practice"
        }
    }
}

struct MicroLessonSessionView: View {
    let lesson: MicroLessonDTO
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var currentItem = 0
    @State private var showingResult = false
    @State private var userAnswer = ""
    @State private var isCorrect = false
    @State private var timeRemaining = 0
    
    private var totalItems: Int { lesson.items.count }
    private var progress: Double { Double(currentItem) / Double(totalItems) }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.iWingSurface.ignoresSafeArea()
                
                VStack(spacing: .iWingPadding) {
                    // Progress Header
                    VStack(spacing: .iWingPaddingSmall) {
                        HStack {
                            Text("\(currentItem + 1) of \(totalItems)")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                            
                            Spacer()
                            
                            Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingAccent)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .iWingAccent))
                    }
                    .padding(.horizontal, .iWingPadding)
                    
                    // Lesson Content
                    if currentItem < totalItems {
                        VStack(spacing: .iWingPadding) {
                            Text(lessonTitle(for: lesson.kind))
                                .font(.iWingTitle)
                                .foregroundColor(.iWingTextPrimary)
                                .multilineTextAlignment(.center)
                            
                            // Content based on lesson type
                            switch lesson.kind {
                            case 0: // Words
                                WordsPracticeView(
                                    word: lesson.items[currentItem],
                                    userAnswer: $userAnswer,
                                    isCorrect: $isCorrect
                                )
                            case 1: // Pattern
                                PatternExerciseView(
                                    pattern: lesson.items[currentItem],
                                    userAnswer: $userAnswer,
                                    isCorrect: $isCorrect
                                )
                            case 2: // Dictation
                                DictationView(
                                    text: lesson.items[currentItem],
                                    userAnswer: $userAnswer,
                                    isCorrect: $isCorrect
                                )
                            default:
                                Text("Unknown lesson type")
                            }
                            
                            // Action Buttons
                            VStack(spacing: .iWingPaddingSmall) {
                                Button(action: {
                                    HapticEngine.play(.light)
                                    if isCorrect {
                                        nextItem()
                                    } else {
                                        checkAnswer()
                                    }
                                }) {
                                    Text(isCorrect ? "Next" : "Check")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(IWingAccentButtonStyle())
                                .disabled(userAnswer.isEmpty)
                                .opacity(userAnswer.isEmpty ? 0.5 : 1.0)
                                
                                Button(action: {
                                    HapticEngine.play(.light)
                                    nextItem()
                                }) {
                                    Text("Skip")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(IWingPrimaryButtonStyle())
                            }
                        }
                        .padding()
                    } else {
                        // Completion Screen
                        CompletionView {
                            onComplete()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Micro Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticEngine.play(.light)
                        dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
        .onAppear {
            timeRemaining = lesson.estimatedSec
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                // Auto-complete lesson
                onComplete()
                dismiss()
            }
        }
    }
    
    private func checkAnswer() {
        // Simple answer checking logic
        isCorrect = !userAnswer.isEmpty
    }
    
    private func nextItem() {
        if currentItem < totalItems - 1 {
            currentItem += 1
            userAnswer = ""
            isCorrect = false
        } else {
            // Move to completion
            currentItem = totalItems
        }
    }
    
    private func lessonTitle(for kind: Int) -> String {
        switch kind {
        case 0: return "Words Practice"
        case 1: return "Pattern Exercise"
        case 2: return "Mini Dictation"
        default: return "Micro Lesson"
        }
    }
}

struct WordsPracticeView: View {
    let word: String
    @Binding var userAnswer: String
    @Binding var isCorrect: Bool
    
    var body: some View {
        VStack(spacing: .iWingPadding) {
            Text("Translate this word:")
                .font(.iWingBody)
                .foregroundColor(.iWingTextMuted)
            
            Text(word)
                .font(.iWingTitle)
                .foregroundColor(.iWingTextPrimary)
                .padding()
                .background(Color.iWingSurface)
                .cornerRadius(.iWingCornerRadius)
            
            TextField("Your translation", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.iWingBody)
        }
    }
}

struct PatternExerciseView: View {
    let pattern: String
    @Binding var userAnswer: String
    @Binding var isCorrect: Bool
    
    var body: some View {
        VStack(spacing: .iWingPadding) {
            Text("Complete the pattern:")
                .font(.iWingBody)
                .foregroundColor(.iWingTextMuted)
            
            Text(pattern)
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.iWingSurface)
                .cornerRadius(.iWingCornerRadius)
            
            TextField("Your answer", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.iWingBody)
        }
    }
}

struct DictationView: View {
    let text: String
    @Binding var userAnswer: String
    @Binding var isCorrect: Bool
    
    var body: some View {
        VStack(spacing: .iWingPadding) {
            Text("Type the following text:")
                .font(.iWingBody)
                .foregroundColor(.iWingTextMuted)
            
            Text(text)
                .font(.iWingHeadline)
                .foregroundColor(.iWingTextPrimary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.iWingSurface)
                .cornerRadius(.iWingCornerRadius)
            
            TextField("Type here", text: $userAnswer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.iWingBody)
                .padding(.top, .iWingPaddingSmall)
        }
    }
}

struct CompletionView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: .iWingPadding) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.iWingSuccess)
            
            Text("Lesson Complete!")
                .font(.iWingTitle)
                .foregroundColor(.iWingTextPrimary)
            
            Text("Great job! You've completed this micro-lesson.")
                .font(.iWingBody)
                .foregroundColor(.iWingTextMuted)
                .multilineTextAlignment(.center)
            
            Button(action: {
                HapticEngine.play(.success)
                onComplete()
            }) {
                Text("Done")
            }
            .buttonStyle(IWingAccentButtonStyle())
        }
        .padding()
    }
}

struct MicroLessonSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.iWingSurface.ignoresSafeArea()
                
                VStack(spacing: .iWingPadding) {
                    Text("Micro-lesson Settings")
                        .font(.iWingTitle)
                        .foregroundColor(.iWingTextPrimary)
                    
                    Text("Configure your micro-lesson preferences")
                        .font(.iWingBody)
                        .foregroundColor(.iWingTextMuted)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticEngine.play(.light)
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class MicroLessonsViewModel: ObservableObject {
    @Published var queueLessons: [MicroLessonDTO] = []
    @Published var completedToday = 0
    
    private let microLessonRepository: MicroLessonRepository
    private let completeMicroLessonUseCase: CompleteMicroLessonUseCase
    
    var queueCount: Int { queueLessons.count }
    
    init() {
        let container = DIContainer.shared
        self.microLessonRepository = container.microLessonRepository
        self.completeMicroLessonUseCase = container.completeMicroLessonUseCase
    }
    
    func loadQueue() async {
        do {
            queueLessons = try await microLessonRepository.queueForToday()
        } catch {
            print("Error loading micro-lessons: \(error)")
        }
        
        completedToday = 2 // Sample data
    }
    
    func completeLesson(_ id: UUID) async {
        do {
            try await completeMicroLessonUseCase.execute(id: id)
            queueLessons.removeAll { $0.id == id }
            completedToday += 1
        } catch {
            print("Error completing lesson: \(error)")
        }
    }
}

#Preview {
    MicroLessonsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
