import SwiftUI
import CoreData
import Combine

public class ResultScreenVM: ObservableObject {
    @Published public var donut: RiskDonutModel?
    @Published public var featureStack: FeatureStackedModel?
    @Published public var canScheduleReminder: Bool = false
    @Published public var showingNoteSheet: Bool = false
    @Published public var noteText: String = ""
    @Published public var showReminderAlert: Bool = false
    @Published public var reminderScheduled: Bool = false
    
    private let session: CheckSessionDTO
    private let donutUC: BuildRiskDonutUC
    private let featureUC: BuildFeatureStackedUC
    private let scheduleUC: ScheduleFollowUpUC
    private let sessionRepo: CheckSessionRepository
    
    public var riskLevel: RiskLevel {
        RiskLevel(rawValue: session.riskLevel) ?? .low
    }
    
    public init(
        session: CheckSessionDTO,
        donutUC: BuildRiskDonutUC,
        featureUC: BuildFeatureStackedUC,
        scheduleUC: ScheduleFollowUpUC,
        sessionRepo: CheckSessionRepository
    ) {
        self.session = session
        self.donutUC = donutUC
        self.featureUC = featureUC
        self.scheduleUC = scheduleUC
        self.sessionRepo = sessionRepo
        
        self.donut = donutUC.performInvocation(sessionId: session.id)
        self.featureStack = featureUC.performInvocation(sessionId: session.id)
        self.canScheduleReminder = (session.riskLevel == 0 || session.riskLevel == 1)
        self.noteText = session.note ?? ""
    }
    
    public func scheduleTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let targetTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow)!
        scheduleUC.performInvocation(sessionId: session.id, at: targetTime)
        reminderScheduled = true
        showReminderAlert = true
    }
    
    public func saveNote() {
        _ = sessionRepo.setNote(sessionId: session.id, note: noteText.isEmpty ? nil : noteText)
    }
    
    public func recommendations() -> [RecommendationItem] {
        let level = riskLevel
        
        switch level {
        case .low:
            return [
                RecommendationItem(icon: "arrow.down.circle", text: "Reduce volume/intensity slightly", priority: .normal),
                RecommendationItem(icon: "figure.flexibility", text: "5-10 min gentle mobility work", priority: .normal),
                RecommendationItem(icon: "eye", text: "Monitor symptoms", priority: .normal),
                RecommendationItem(icon: "arrow.clockwise", text: "Recheck tomorrow if persists", priority: .normal)
            ]
            
        case .medium:
            return [
                RecommendationItem(icon: "bed.double", text: "Rest for 24-48 hours", priority: .medium),
                RecommendationItem(icon: "snowflake", text: "Apply ice 10-15 min, 2-3 times", priority: .normal),
                RecommendationItem(icon: "eye", text: "Monitor swelling", priority: .normal),
                RecommendationItem(icon: "arrow.clockwise", text: "Recheck after 24 hours", priority: .normal),
                RecommendationItem(icon: "xmark.circle", text: "Avoid aggravating movements", priority: .medium)
            ]
            
        case .high:
            return [
                RecommendationItem(icon: "stop.circle", text: "Stop training immediately", priority: .high),
                RecommendationItem(icon: "snowflake", text: "Apply ice and compress if swelling", priority: .medium),
                RecommendationItem(icon: "arrow.up.circle", text: "Elevate the area", priority: .normal),
                RecommendationItem(icon: "stethoscope", text: "Consult healthcare provider", priority: .high),
                RecommendationItem(icon: "exclamationmark.triangle", text: "Do not push through pain", priority: .high)
            ]
            
        case .red:
            return [
                RecommendationItem(icon: "stop.fill", text: "Stop all activity now", priority: .critical),
                RecommendationItem(icon: "cross.circle", text: "Seek medical attention urgently", priority: .critical),
                RecommendationItem(icon: "snowflake", text: "Apply RICE protocol", priority: .high),
                RecommendationItem(icon: "clock.badge.exclamationmark", text: "Do not delay consultation", priority: .critical),
                RecommendationItem(icon: "person.badge.shield.checkmark", text: "This requires professional assessment", priority: .high)
            ]
        }
    }
}

// MARK: - Recommendation Model

public struct RecommendationItem: Identifiable {
    public let id = UUID()
    public let icon: String
    public let text: String
    public let priority: Priority
    
    public enum Priority {
        case normal, medium, high, critical
        
        var color: Color {
            switch self {
            case .normal: return ThemeColorsConfig.accentBright
            case .medium: return Color(hex: "FFB84D")
            case .high: return ThemeColorsConfig.accentWarm
            case .critical: return Color(hex: "FF5A5A")
            }
        }
    }
    
    public init(icon: String, text: String, priority: Priority) {
        self.icon = icon
        self.text = text
        self.priority = priority
    }
}

// MARK: - Main View

public struct ResultScreenView: View {
    @StateObject var viewModel: ResultScreenVM
    let onDismiss: () -> Void
    
    @State private var appeared = false
    @State private var showChart = false
    @State private var recommendationsAppeared: [Bool] = []
    @State private var showCelebration = false
    
    public init(viewModel: ResultScreenVM, onDismiss: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            ThemeColorsConfig.backgroundDeep
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                ZStack {
                    // Centered title
                    Text("Results")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    // Back button on the left
                    HStack {
                        Button {
                            print("🔙 Back button tapped in ResultScreenView")
                            onDismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .regular))
                            }
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(ThemeColorsConfig.backgroundDeep)
                
                // Celebration particles for low risk
                ZStack {
                    if showCelebration && viewModel.riskLevel == .low {
                        CelebrationView()
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                    
                    ScrollView {
                        VStack(spacing: 28) {
                            // Risk Result Card
                            RiskResultCard(
                                riskLevel: viewModel.riskLevel,
                                donut: viewModel.donut,
                                showChart: showChart
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Medical Disclaimer
                            DisclaimerBanner()
                                .padding(.horizontal, 20)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)
                            
                            // Recommendations
                            RecommendationsCard(
                                recommendations: viewModel.recommendations(),
                                riskLevel: viewModel.riskLevel,
                                recommendationsAppeared: recommendationsAppeared
                            )
                            .padding(.horizontal, 20)
                            
                            // Feature Stack
                            if let featureStack = viewModel.featureStack {
                                FeatureBreakdownCard(model: featureStack, appeared: appeared)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Actions
                            ActionsSection(
                                viewModel: viewModel,
                                appeared: appeared,
                                onDismiss: onDismiss
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showingNoteSheet) {
            NoteSheetView(
                noteText: $viewModel.noteText,
                onSave: {
                    viewModel.saveNote()
                    viewModel.showingNoteSheet = false
                },
                onCancel: {
                    viewModel.showingNoteSheet = false
                }
            )
        }
        .alert("Reminder Set", isPresented: $viewModel.showReminderAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You'll receive a reminder tomorrow at 7:00 PM to recheck your symptoms")
        }
        .onAppear {
            recommendationsAppeared = Array(repeating: false, count: viewModel.recommendations().count)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showChart = true
            }
            
            // Staggered recommendations
            for i in 0..<viewModel.recommendations().count {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + Double(i) * 0.08)) {
                    if i < recommendationsAppeared.count {
                        recommendationsAppeared[i] = true
                    }
                }
            }
            
            // Celebration for low risk
            if viewModel.riskLevel == .low {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCelebration = true
                }
            }
        }
    }
}

// MARK: - Risk Result Card

struct RiskResultCard: View {
    let riskLevel: RiskLevel
    let donut: RiskDonutModel?
    let showChart: Bool
    
    @State private var pulseRing = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated Risk Indicator
            ZStack {
                // Pulse rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(riskLevel.color.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(160 + i * 30), height: CGFloat(160 + i * 30))
                        .scaleEffect(pulseRing ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.3),
                            value: pulseRing
                        )
                }
                
                // Main circle
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    riskLevel.color.opacity(0.3),
                                    riskLevel.color.opacity(0.05)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .stroke(riskLevel.color.opacity(0.5), lineWidth: 3)
                        .frame(width: 140, height: 140)
                    
                    VStack(spacing: 8) {
                        Image(systemName: riskLevel.iconName)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(riskLevel.color)
                        
                        Text(riskLevel.shortName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(riskLevel.color)
                    }
                }
                .scaleEffect(showChart ? 1 : 0.5)
                .opacity(showChart ? 1 : 0)
            }
            
            // Risk Level Text
            VStack(spacing: 8) {
                Text(riskLevel.displayName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text(riskLevel.subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .multilineTextAlignment(.center)
            }
            .opacity(showChart ? 1 : 0)
            .offset(y: showChart ? 0 : 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(riskLevel.color.opacity(0.25), lineWidth: 1)
                )
        )
        .shadow(color: riskLevel.color.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            pulseRing = true
        }
    }
}

// MARK: - Disclaimer Banner

struct DisclaimerBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(ThemeColorsConfig.accentWarm)
            
            Text("This is not medical advice. Consult a healthcare professional for diagnosis.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.9))
                .lineSpacing(2)
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(ThemeColorsConfig.accentWarm.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(ThemeColorsConfig.accentWarm.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Recommendations Card

struct RecommendationsCard: View {
    let recommendations: [RecommendationItem]
    let riskLevel: RiskLevel
    let recommendationsAppeared: [Bool]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(riskLevel.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "checklist")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(riskLevel.color)
                }
                
                Text("What to Do Today")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            // Recommendations list
            VStack(spacing: 0) {
                ForEach(Array(recommendations.enumerated()), id: \.element.id) { index, rec in
                    RecommendationRow(
                        item: rec,
                        index: index,
                        isLast: index == recommendations.count - 1,
                        isVisible: index < recommendationsAppeared.count ? recommendationsAppeared[index] : false
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct RecommendationRow: View {
    let item: RecommendationItem
    let index: Int
    let isLast: Bool
    let isVisible: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(item.priority.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(item.priority.color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                        .lineSpacing(2)
                    
                    if item.priority == .critical {
                        Text("URGENT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(item.priority.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(item.priority.color.opacity(0.15))
                            )
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : -20)
            
            if !isLast {
                Rectangle()
                    .fill(ThemeColorsConfig.neutralMuted.opacity(0.2))
                    .frame(height: 1)
                    .padding(.leading, 54)
            }
        }
    }
}

// MARK: - Feature Breakdown Card

struct FeatureBreakdownCard: View {
    let model: FeatureStackedModel
    let appeared: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentBright)
                
                Text("Risk Factors")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            FeatureStackedBarView(model: model)
                .frame(height: 100)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.25), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appeared)
    }
}

// MARK: - Actions Section

struct ActionsSection: View {
    @ObservedObject var viewModel: ResultScreenVM
    let appeared: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Reminder button
            if viewModel.canScheduleReminder {
                ActionButton(
                    title: viewModel.reminderScheduled ? "Reminder Set" : "Remind Me Tomorrow",
                    icon: viewModel.reminderScheduled ? "checkmark.circle.fill" : "bell.badge",
                    style: .primary,
                    disabled: viewModel.reminderScheduled
                ) {
                    viewModel.scheduleTomorrow()
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
            
            // Note button
            ActionButton(
                title: viewModel.noteText.isEmpty ? "Add Note" : "Edit Note",
                icon: "note.text.badge.plus",
                style: .secondary
            ) {
                viewModel.showingNoteSheet = true
            }
            
            // Done button
            ActionButton(
                title: "Done",
                icon: "checkmark",
                style: .primary
            ) {
                onDismiss()
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appeared)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let style: Style
    var disabled: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum Style {
        case primary, secondary, tertiary
    }
    
    var body: some View {
        Button(action: {
            guard !disabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
            )
            .opacity(disabled ? 0.6 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.97 : 1)
        .pressEvents {
            if !disabled {
                withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return ThemeColorsConfig.backgroundDeep
        case .secondary: return ThemeColorsConfig.primaryLight
        case .tertiary: return ThemeColorsConfig.neutralAxis
        }
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [ThemeColorsConfig.accentBright, ThemeColorsConfig.accentBright.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            ThemeColorsConfig.backgroundCard
        case .tertiary:
            ThemeColorsConfig.neutralMuted.opacity(0.2)
        }
    }
    
    private var borderColor: Color {
        style == .secondary ? ThemeColorsConfig.neutralMuted.opacity(0.3) : .clear
    }
}

// MARK: - Note Sheet

struct NoteSheetView: View {
    @Binding var noteText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var appeared = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    
                    Spacer()
                    
                    Text("Add Note")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    Spacer()
                    
                    Button("Save") {
                        onSave()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentBright)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(ThemeColorsConfig.backgroundDeep)
                
                ZStack {
                    ThemeColorsConfig.backgroundDeep
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Text editor
                        VStack(alignment: .leading, spacing: 12) {
                        Text("Your note")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                        
                        ZStack(alignment: .topLeading) {
                            if noteText.isEmpty {
                                Text("Add any details about your symptoms, what you were doing, or anything else you want to remember...")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(ThemeColorsConfig.neutralMuted)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                            }
                            
                            TextEditor(text: $noteText)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(ThemeColorsConfig.primaryLight)
                                .focused($isFocused)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .apply { view in
                                    if #available(iOS 16.0, *) {
                                        view.scrollContentBackground(.hidden)
                                    } else {
                                        view
                                    }
                                }
                        }
                        .frame(height: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ThemeColorsConfig.backgroundCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            isFocused ? ThemeColorsConfig.accentBright.opacity(0.5) : ThemeColorsConfig.neutralMuted.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    
                    // Character count
                    HStack {
                        Spacer()
                        Text("\(noteText.count)/280")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(noteText.count > 250 ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.neutralAxis)
                    }
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tips")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                        
                        NoteTipRow(icon: "figure.walk", text: "What activity triggered the symptoms?")
                        NoteTipRow(icon: "clock", text: "Time of day and duration")
                        NoteTipRow(icon: "pills", text: "Any treatments tried")
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(ThemeColorsConfig.backgroundCard.opacity(0.5))
                    )
                    
                        Spacer()
                    }
                    .padding(20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: noteText) { newValue in
            if newValue.count > 280 {
                noteText = String(newValue.prefix(280))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}

struct NoteTipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ThemeColorsConfig.accentBright)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
        }
    }
}

// MARK: - Celebration View

struct CelebrationView: View {
    @State private var particles: [CelebrationParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        let colors: [Color] = [
            ThemeColorsConfig.accentBright,
            ThemeColorsConfig.accentBright.opacity(0.7),
            Color(hex: "34D399"),
            Color(hex: "A78BFA")
        ]
        
        for _ in 0..<30 {
            let particle = CelebrationParticle(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate particles falling
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.5...2.5)
            
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[i].position.y = size.height + 50
                particles[i].position.x += CGFloat.random(in: -50...50)
            }
            
            withAnimation(.easeOut(duration: duration * 0.8).delay(delay + duration * 0.5)) {
                particles[i].opacity = 0
            }
        }
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
}

// MARK: - RiskLevel Extensions

extension RiskLevel {
    var color: Color {
        switch self {
        case .low: return ThemeColorsConfig.accentBright
        case .medium: return Color(hex: "FFB84D")
        case .high: return ThemeColorsConfig.accentWarm
        case .red: return Color(hex: "FF5A5A")
        }
    }
    
    var iconName: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        case .red: return "xmark.shield.fill"
        }
    }
    
    var shortName: String {
        switch self {
        case .low: return "LOW"
        case .medium: return "MEDIUM"
        case .high: return "HIGH"
        case .red: return "RED FLAG"
        }
    }
    
    var displayName: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        case .red: return "Red Flag"
        }
    }
    
    var subtitle: String {
        switch self {
        case .low: return "Likely minor fatigue. Safe to continue with modifications."
        case .medium: return "Some concern. Rest recommended and monitor closely."
        case .high: return "Significant symptoms. Stop activity and consider medical advice."
        case .red: return "Serious signs detected. Seek medical attention promptly."
        }
    }
}

extension View {
    @ViewBuilder
    func apply<V: View>(@ViewBuilder _ transform: (Self) -> V) -> some View {
        transform(self)
    }
}
