// TodayView.swift
import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var showingDialog = false
    @State private var selectedScenario: ScenarioDTO?
    @State private var selectedLesson: MicroLessonDTO?
    @EnvironmentObject private var tabRouter: NavTabRouter
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .iWingPadding) {
                    // Hero Section
                    VStack(spacing: .iWingPadding) {
                        // Useful Time Donut
                        UsefulTimeDonutView(donut: viewModel.donut)
                            .iWingCard()
                            .onTapGesture {
                                viewModel.showDonutSheet = true
                                if viewModel.donut.progress >= 1.0 { HapticEngine.play(.success) }
                                else { HapticEngine.play(.light) }
                            }
                        
                        // Continue Dialog Button
                        if let lastScenario = viewModel.lastScenario {
                            Button(action: {
                                HapticEngine.play(.light)
                                // Ensure scenario is set before showing dialog
                                Task { @MainActor in
                                    selectedScenario = lastScenario
                                    // Small delay to ensure state is updated
                                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
                                    showingDialog = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "mic.fill")
                                    Text("Continue Dialog")
                                    Spacer()
                                    Text(lastScenario.title)
                                        .font(.iWingCaption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding()
                            }
                            .buttonStyle(IWingAccentButtonStyle())
                            .iWingCard()
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                    
                    // Quick Topics Section
                    VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                        HStack {
                            Text("Quick Topics")
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                            Spacer()
                            Button(action: {
                                HapticEngine.play(.light)
                                tabRouter.selectedTab = 2
                            }) {
                                Text("Explore")
                                    .font(.iWingCaption)
                                    .foregroundColor(.iWingAccent)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .iWingPaddingSmall) {
                                ForEach(viewModel.quickTopics, id: \.self) { topic in
                                    QuickTopicCardView(topic: topic, isSelected: viewModel.selectedTopics.contains(topic)) {
                                        HapticEngine.play(.light)
                                        viewModel.selectTopic(topic)
                                    }
                                }
                            }
                            .padding(.horizontal, .iWingPadding)
                        }
                    }
                    .padding(.horizontal, .iWingPadding)
                    
                    // Micro-lessons Queue
                    if !viewModel.queueLessons.isEmpty {
                        VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                            Text("Micro-lessons Queue")
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                            
                            VStack(spacing: .iWingPaddingSmall) {
                                ForEach(viewModel.queueLessons.prefix(3)) { lesson in
                                    MicroLessonCardView(lesson: lesson) {
                                        HapticEngine.play(.light)
                                        selectedLesson = lesson
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, .iWingPadding)
                    }
                    
                    // Recent Activity
                    if !viewModel.recentActivity.isEmpty {
                        VStack(alignment: .leading, spacing: .iWingPaddingSmall) {
                            Text("Recent Activity")
                                .font(.iWingHeadline)
                                .foregroundColor(.iWingTextPrimary)
                            
                            VStack(spacing: .iWingPaddingSmall) {
                                ForEach(viewModel.recentActivity.prefix(3)) { activity in
                                    RecentActivityCardView(activity: activity)
                                }
                            }
                        }
                        .padding(.horizontal, .iWingPadding)
                    }
                }
                .padding(.vertical, .iWingPadding)
            }
            .fillGradientBackground()
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task {
                    await viewModel.load()
                }
            }
        }
        .sheet(isPresented: $viewModel.showDonutSheet) {
            DonutBreakdownSheet(donut: viewModel.donut)
        }
        .sheet(isPresented: $showingDialog) {
            if let scenario = selectedScenario {
                DialogSessionView(scenario: scenario) {
                    showingDialog = false
                    selectedScenario = nil
                }
            } else {
                // Show loading indicator while scenario is being set
                ZStack {
                    Color.iWingSurface.ignoresSafeArea()
                    VStack(spacing: .iWingPadding) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading conversation...")
                            .font(.iWingBody)
                            .foregroundColor(.iWingTextMuted)
                    }
                }
                .presentationDetents([.large])
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            MicroLessonSessionView(lesson: lesson) {
                viewModel.completeLesson(lesson.id)
            }
        }
    }
}

// MARK: - Supporting Views
struct UsefulTimeDonutView: View {
    let donut: UsefulDonutModel
    
    var body: some View {
        VStack(spacing: .iWingPaddingSmall) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.iWingSurface.opacity(0.16), lineWidth: 16)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: donut.progress)
                    .stroke(Color.iWingAccent, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: donut.progress)
                
                // Center text
                VStack {
                    Text("\(donut.usefulMinutes)")
                        .font(.iWingTitle)
                        .foregroundColor(.iWingTextPrimary)
                    Text("min")
                        .font(.iWingCaption)
                        .foregroundColor(.iWingTextMuted)
                    Text("of \(donut.dailyGoalMinutes)")
                        .font(.iWingSmall)
                        .foregroundColor(.iWingTextMuted)
                }
            }
            
            Text("Useful Time Today")
                .font(.iWingCaption)
                .foregroundColor(.iWingTextMuted)
        }
        .padding()
    }
}

struct DonutBreakdownSheet: View {
    let donut: UsefulDonutModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabRouter: NavTabRouter
    
    var body: some View {
        ZStack {
            Color.iWingSurface.ignoresSafeArea()
            
            VStack(spacing: .iWingPadding) {
                Spacer().frame(height: .iWingPaddingSmall)
                
                Text("Useful Time")
                    .font(.iWingHeadline)
                    .foregroundColor(.iWingTextPrimary)
                
                Text("\(donut.usefulMinutes) min of \(donut.dailyGoalMinutes)")
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextMuted)
                
                Spacer().frame(height: .iWingPaddingSmall)
                
                VStack(spacing: .iWingPaddingSmall) {
                    Button(action: {
                        HapticEngine.play(.light)
                        tabRouter.selectedTab = 1
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                            Text("Start Dialog")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(IWingAccentButtonStyle())
                    
                    Button(action: {
                        HapticEngine.play(.light)
                        tabRouter.selectedTab = 2
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Open Immersion")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(IWingPrimaryButtonStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, .iWingPadding)
        }
        .presentationDetents([.fraction(0.35), .medium])
        .presentationDragIndicator(.visible)
    }
}

struct MicroLessonCardView: View {
    let lesson: MicroLessonDTO
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(lessonTitle(for: lesson.kind))
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextPrimary)
                
                Text("~\(lesson.estimatedSec / 60) min")
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextMuted)
            }
            
            Spacer()
            
            Button(action: {
                HapticEngine.play(.light)
                onComplete()
            }) {
                Text("Start")
            }
            .buttonStyle(IWingPrimaryButtonStyle())
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
}

struct RecentActivityCardView: View {
    let activity: RecentActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundColor(.iWingAccent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.iWingBody)
                    .foregroundColor(.iWingTextPrimary)
                
                Text(activity.subtitle)
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextMuted)
            }
            
            Spacer()
            
            Text(activity.timeAgo)
                .font(.iWingSmall)
                .foregroundColor(.iWingTextMuted)
        }
        .padding()
        .iWingCard()
    }
}

struct QuickTopicCardView: View {
    let topic: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private let topicIcons: [String: String] = [
        "IT": "laptopcomputer",
        "Movies": "film",
        "Travel": "airplane",
        "UX": "paintbrush",
        "Sports": "figure.run",
        "Food": "fork.knife"
    ]
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .iWingPaddingSmall) {
                Image(systemName: topicIcons[topic] ?? "star.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : .iWingAccent)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? Color.iWingAccent : Color.iWingSurface)
                    .cornerRadius(.iWingCornerRadius)
                
                Text(topic)
                    .font(.iWingCaption)
                    .foregroundColor(.iWingTextPrimary)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models
struct RecentActivity: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let timeAgo: String
}

// MARK: - ViewModel
@MainActor
class TodayViewModel: ObservableObject {
    @Published var donut = UsefulDonutModel(dayKey: Date(), usefulMinutes: 0, dailyGoalMinutes: 20)
    @Published var lastScenario: ScenarioDTO?
    @Published var quickTopics = ["IT", "Movies", "Travel", "UX", "Sports", "Food"]
    @Published var selectedTopics: Set<String> = []
    @Published var queueLessons: [MicroLessonDTO] = []
    @Published var recentActivity: [RecentActivity] = []
    @Published var showDonutSheet = false
    
    private let donutUseCase: BuildUsefulDonutUseCase
    private let microLessonRepository: MicroLessonRepository
    private let scenarioRepository: ScenarioRepository
    
    init() {
        let container = DIContainer.shared
        self.donutUseCase = container.buildUsefulDonutUseCase
        self.microLessonRepository = container.microLessonRepository
        self.scenarioRepository = container.scenarioRepository
    }
    
    func load() async {
        do {
            let dayKey = Date().dayKey
            donut = try await donutUseCase.execute(dayKey: dayKey)
            queueLessons = try await microLessonRepository.queueForToday()
            lastScenario = try await scenarioRepository.listAll(minLevel: nil).first
        } catch {
            print("Error loading today's data: \(error)")
        }
        
        recentActivity = [
            RecentActivity(title: "New word added", subtitle: "restaurant", icon: "plus.circle", timeAgo: "2h ago"),
            RecentActivity(title: "Dialog completed", subtitle: "Restaurant Order", icon: "mic", timeAgo: "4h ago"),
            RecentActivity(title: "Pattern learned", subtitle: "used to", icon: "checkmark.circle", timeAgo: "1d ago")
        ]
    }
    
    func selectTopic(_ topic: String) {
        if selectedTopics.contains(topic) {
            selectedTopics.remove(topic)
        } else {
            selectedTopics.insert(topic)
        }
    }
    
    func completeLesson(_ id: UUID) {
        queueLessons.removeAll { $0.id == id }
    }
}

#Preview {
    TodayView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
