// DialogView.swift
import SwiftUI

struct DialogView: View {
    @StateObject private var viewModel = DialogViewModel()
    @State private var selectedScenario: ScenarioDTO?
    @State private var showingDialog = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: .iWingPaddingLarge) {
                Text("Choose a Dialog Scenario")
                    .font(.iWingTitle)
                    .foregroundColor(.iWingTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Practice real conversations with AI")
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextMuted)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    VStack(spacing: .iWingPaddingSmall) {
                        ForEach(viewModel.availableScenarios) { scenario in
                            ScenarioCardView(scenario: scenario) {
                                HapticEngine.play(.light)
                                selectedScenario = scenario
                                showingDialog = true
                            }
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                }
            }
            .padding(.top, .iWingPaddingLarge)
            .fillGradientBackground()
            .navigationTitle("Dialog")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await viewModel.loadScenarios()
                }
            }
            .sheet(isPresented: $showingDialog) {
                if let scenario = selectedScenario {
                    DialogSessionView(scenario: scenario) {
                        showingDialog = false
                        selectedScenario = nil
                    }
                }
            }
        }
    }
}

struct ScenarioCardView: View {
    let scenario: ScenarioDTO
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                HStack {
                    Text(scenario.title)
                        .font(.iWingHeadline)
                        .foregroundColor(.iWingTextPrimary)
                    
                    Spacer()
                    
                    Text(levelText(for: scenario.levelMin))
                        .font(.iWingCaption)
                        .iWingChip()
                }
                
                Text(scenario.goals.prefix(2).joined(separator: " • "))
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextMuted)
                    .lineLimit(1)
                
                HStack {
                    ForEach(scenario.topics.prefix(3), id: \.self) { topic in
                        Text(topic)
                            .font(.iWingSmall)
                            .iWingChip()
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .iWingCard()
    }
    
    private func levelText(for level: Int) -> String {
        switch level {
        case 1: return "A2"
        case 2: return "B1"
        case 3: return "B2"
        default: return "Beginner"
        }
    }
}

struct DialogSessionView: View {
    let scenario: ScenarioDTO
    let onClose: () -> Void
    @StateObject private var viewModel: DialogSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(scenario: ScenarioDTO, onClose: @escaping () -> Void) {
        self.scenario = scenario
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: DialogSessionViewModel(scenario: scenario))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.iWingSurface.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Scenario Info Header
                    VStack(spacing: .iWingPaddingSmall) {
                        Text(scenario.title)
                            .font(.iWingHeadline)
                            .foregroundColor(.iWingTextPrimary)
                        
                        Text("Level: \(scenario.levelMin)")
                            .font(.iWingCaption)
                            .foregroundColor(.iWingTextMuted)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.iWingSurface)
                    
                    Divider()
                    
                    // Conversation Transcript
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: .iWingPaddingSmall) {
                                ForEach(viewModel.transcript) { turn in
                                    DialogTurnView(turn: turn)
                                        .id(turn.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.transcript.count) { _ in
                            if let lastTurn = viewModel.transcript.last {
                                withAnimation {
                                    proxy.scrollTo(lastTurn.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // User Input Area
                    VStack(spacing: .iWingPaddingSmall) {
                        if viewModel.isAISpeaking {
                            HStack {
                                ProgressView()
                                Text("AI is responding...")
                                    .font(.iWingCaption)
                                    .foregroundColor(.iWingTextMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            VStack(spacing: .iWingPaddingSmall) {
                                TextField("Type your response...", text: $viewModel.userInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.iWingBody)
                                    .disabled(viewModel.isProcessing)
                                
                                HStack(spacing: .iWingPaddingSmall) {
                                    Button(action: {
                                        HapticEngine.play(.light)
                                        viewModel.showHint()
                                    }) {
                                        HStack {
                                            Image(systemName: "lightbulb")
                                            Text("Hint")
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(IWingPrimaryButtonStyle())
                                    .disabled(viewModel.isProcessing)
                                    
                                    Button(action: {
                                        HapticEngine.play(.medium)
                                        Task {
                                            await viewModel.sendMessage()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "paperplane.fill")
                                            Text("Send")
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(IWingAccentButtonStyle())
                                    .disabled(viewModel.userInput.isEmpty || viewModel.isProcessing)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(Color.iWingSurface)
                }
            }
            .navigationTitle("Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticEngine.play(.light)
                        onClose()
                        dismiss()
                    }) {
                        Text("Close")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Make Easier") {
                            HapticEngine.play(.light)
                            viewModel.adjustDifficulty(easier: true)
                        }
                        Button("Make Harder") {
                            HapticEngine.play(.light)
                            viewModel.adjustDifficulty(easier: false)
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.startConversation()
            }
        }
    }
}

struct DialogTurnView: View {
    let turn: DialogTurnDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: .iWingPaddingSmall) {
            if !turn.speakerIsAI {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(turn.text)
                        .font(.iWingBody)
                        .foregroundColor(.white)
                        .padding(.horizontal, .iWingPadding)
                        .padding(.vertical, .iWingPaddingSmall)
                        .background(Color.iWingAccent)
                        .cornerRadius(.iWingCornerRadius)
                    
                    if !turn.marks.isEmpty {
                        ForEach(turn.marks, id: \.self) { mark in
                            Text("• \(mark)")
                                .font(.iWingCaption)
                                .foregroundColor(.iWingTextMuted)
                        }
                    }
                }
                
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.iWingAccent)
                    .font(.system(size: 32))
            } else {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.iWingTextMuted)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(turn.text)
                        .font(.iWingBody)
                        .foregroundColor(.iWingTextPrimary)
                        .padding(.horizontal, .iWingPadding)
                        .padding(.vertical, .iWingPaddingSmall)
                        .background(Color.white)
                        .cornerRadius(.iWingCornerRadius)
                }
                
                Spacer()
            }
        }
    }
    
    private func markColor(for kind: Int) -> Color {
        switch kind {
        case 0: return .iWingSuccess
        case 1: return .yellow
        case 2: return .red
        default: return .iWingTextMuted
        }
    }
}

// MARK: - ViewModel
@MainActor
class DialogViewModel: ObservableObject {
    @Published var availableScenarios: [ScenarioDTO] = []
    
    private let scenarioRepository: ScenarioRepository
    
    init() {
        self.scenarioRepository = DIContainer.shared.scenarioRepository
    }
    
    func loadScenarios() async {
        do {
            availableScenarios = try await scenarioRepository.listAll(minLevel: nil)
        } catch {
            print("Error loading scenarios: \(error)")
        }
    }
}

@MainActor
class DialogSessionViewModel: ObservableObject {
    @Published var transcript: [DialogTurnDTO] = []
    @Published var userInput = ""
    @Published var isProcessing = false
    @Published var isAISpeaking = false
    @Published var currentHint: String?
    
    private let scenario: ScenarioDTO
    private var turnCount = 0
    private let maxTurns = 10
    
    init(scenario: ScenarioDTO) {
        self.scenario = scenario
    }
    
    func startConversation() async {
        isAISpeaking = true
        
        // Simulate AI starting the conversation
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let greeting = "Hello! Let's practice \(scenario.title). How are you today?"
        let aiTurn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: true,
            text: greeting,
            marks: []
        )
        
        transcript.append(aiTurn)
        turnCount += 1
        isAISpeaking = false
    }
    
    func sendMessage() async {
        guard !userInput.isEmpty else { return }
        
        isProcessing = true
        
        // Add user's message
        let userTurn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: false,
            text: userInput,
            marks: []
        )
        transcript.append(userTurn)
        
        let userMessage = userInput
        userInput = ""
        turnCount += 1
        
        // Simulate processing
        isAISpeaking = true
        isProcessing = false
        
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Generate AI response
        let aiResponse = generateAIResponse(to: userMessage)
        let aiTurn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: true,
            text: aiResponse,
            marks: []
        )
        
        transcript.append(aiTurn)
        turnCount += 1
        isAISpeaking = false
        
        // Check if conversation should end
        if turnCount >= maxTurns {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let endTurn = DialogTurnDTO(
                id: UUID(),
                ts: Date(),
                speakerIsAI: true,
                text: "Great conversation! You're making good progress. Let's practice again soon!",
                marks: []
            )
            transcript.append(endTurn)
        }
    }
    
    func showHint() {
        let hints = [
            "Try asking a question about the topic.",
            "Describe your experience or opinion.",
            "Use complete sentences.",
            "Try using past tense verbs.",
            "Add more details to your response."
        ]
        currentHint = hints.randomElement()
        
        let hintTurn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: true,
            text: "💡 Hint: \(currentHint ?? "Keep going!")",
            marks: []
        )
        transcript.append(hintTurn)
    }
    
    func adjustDifficulty(easier: Bool) {
        let message = easier ? "Making responses simpler..." : "Increasing difficulty..."
        let adjustTurn = DialogTurnDTO(
            id: UUID(),
            ts: Date(),
            speakerIsAI: true,
            text: "⚙️ \(message)",
            marks: []
        )
        transcript.append(adjustTurn)
    }
    
    private func generateAIResponse(to userMessage: String) -> String {
        let responses = [
            "That's interesting! Tell me more about that.",
            "I see. What do you think about this?",
            "Great! Can you explain in more detail?",
            "Interesting perspective. How did you come to that conclusion?",
            "I understand. What else would you like to discuss?",
            "That makes sense. Could you give an example?",
            "Excellent point! Have you considered this aspect?",
            "I appreciate your thoughts on this. What's your next step?"
        ]
        
        return responses.randomElement() ?? "Could you elaborate on that?"
    }
}

#Preview {
    DialogView()
}
