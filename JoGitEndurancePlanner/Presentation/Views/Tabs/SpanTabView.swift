import SwiftUI

struct SpanTabView: View {
    @StateObject var viewModel: SpanViewModel
    @State private var showingExport = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundDeep
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Spacer()
                    
                    Text("Week")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                }
                .frame(height: 44)
                .background(AppTheme.surfaceDark)
                .overlay(alignment: .trailing) {
                    Button(action: { showingExport = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.goldPrimary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(AppTheme.goldPrimary.opacity(0.1))
                            )
                    }
                    .disabled(!viewModel.isInitialLoadComplete)
                    .padding(.trailing, 12)
                }
                
                if !viewModel.isInitialLoadComplete {
                    LoadingStateView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            headerSection
                            
                            headerCard
                            
                            // Show verdict text above the ring if no workouts
                            if let ringData = viewModel.ringData, ringData.verdictText == "No workouts completed" {
                                Text(ringData.verdictText)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(.top, 8)
                            }
                            
                            TargetActualRingView(data: viewModel.ringData)
                                .padding(.horizontal)
                            
                            summaryCard
                            
                            WeeklyBarsView(data: viewModel.barsData)
                                .padding(.horizontal)
                            
                            workoutsList
                            
                            CompletionBarsView(data: viewModel.finishBarsData)
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if viewModel.isInitialLoadComplete {
                AddWorkoutFAB {
                    viewModel.showingAddWorkout = true
                }
                .padding(.trailing, 24)
                .padding(.bottom, 100)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $viewModel.showingAddWorkout) {
            AddWorkoutSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showingExport) {
            ExportSheetView(
                cycle: viewModel.currentCycle,
                workouts: viewModel.workouts,
                ringData: viewModel.ringData
            )
        }
        .onAppear {
            if viewModel.currentCycle == nil {
                viewModel.loadActiveCycle()
            }
            if viewModel.isInitialLoadComplete {
                viewModel.refreshWorkouts()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Deload Week")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Track your recovery sessions")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            if let cycle = viewModel.currentCycle {
                HStack(spacing: 16) {
                    // Rule badge
                    VStack(spacing: 6) {
                        Text("–\(cycle.blueprint.reductionRate)%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        Text("Rule")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .frame(width: 80)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.goldPrimary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.goldDark.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Info
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.goldPrimary)
                            
                            Text("JoGit:EndurancePlanner")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        // Style badge
                        Text(cycle.blueprint.cutbackStyle.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.goldPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(AppTheme.goldPrimary.opacity(0.15))
                            )
                        
                        // Date range
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textMuted)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(cycle.kickoff, style: .date) –")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("\(cycle.closure, style: .date)")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
            } else {
                // Skeleton
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.backgroundElevated)
                        .frame(width: 80, height: 80)
                        .shimmer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.backgroundElevated)
                            .frame(width: 140, height: 12)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppTheme.backgroundElevated)
                            .frame(width: 80, height: 24)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.backgroundElevated)
                            .frame(width: 160, height: 12)
                    }
                    
                    Spacer()
                }
                .shimmer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        Group {
            if let ringData = viewModel.ringData {
                HStack(spacing: 20) {
                    // Target
                    VStack(spacing: 4) {
                        Text("Target")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text("–\(ringData.targetRate)%")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(AppTheme.dividerTint)
                        .frame(width: 1, height: 40)
                    
                    // Actual
                    VStack(spacing: 4) {
                        Text("Actual")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text("–\(ringData.achievedRate)%")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    
                    Spacer()
                    
                    // Verdict badge
                    VerdictBadge(
                        text: ringData.verdictText,
                        isOnTarget: ringData.verdictText == "On Target"
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.surfaceDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.dividerTint, lineWidth: 1)
                        )
                )
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Workouts List
    
    private var workoutsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Sessions", icon: "figure.run")
                .padding(.horizontal)
            
            if viewModel.workouts.isEmpty {
                EmptySessionsCard()
                    .padding(.horizontal)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.workouts) { workout in
                        WorkoutRowView(workout: workout) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleComplete(workout.id)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .id(viewModel.workouts.map { $0.id })
            }
        }
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(AppTheme.goldDark.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AppTheme.goldGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
            }
            
            Text("Loading...")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Verdict Badge

struct VerdictBadge: View {
    let text: String
    let isOnTarget: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isOnTarget ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(isOnTarget ? AppTheme.successGreen : AppTheme.warnYellow)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill((isOnTarget ? AppTheme.successGreen : AppTheme.warnYellow).opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke((isOnTarget ? AppTheme.successGreen : AppTheme.warnYellow).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Empty Sessions Card

struct EmptySessionsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.goldPrimary.opacity(0.1))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.goldDark)
            }
            
            VStack(spacing: 6) {
                Text("No Sessions Yet")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Tap + to add workouts and see\nhow they adjust by your rule")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                )
        )
    }
}

// MARK: - Add Workout FAB

struct AddWorkoutFAB: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow
                Circle()
                    .fill(AppTheme.goldPrimary)
                    .frame(width: 56, height: 56)
                    .blur(radius: 12)
                    .opacity(0.4)
                
                // Button
                Circle()
                    .fill(AppTheme.goldGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.goldLight.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.goldDark.opacity(0.5), radius: 12, y: 6)
                
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.backgroundDeep)
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
        }
    }
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
    let workout: WorkoutEntryModel
    let onToggle: () -> Void
    
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(
                            workout.markedComplete ? AppTheme.successGreen : AppTheme.textMuted,
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)
                    
                    if workout.markedComplete {
                        Circle()
                            .fill(AppTheme.successGreen)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.backgroundDeep)
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    // Day badge
                    Text(dayNames[workout.slotIndex])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.goldPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppTheme.goldPrimary.opacity(0.15))
                        )
                    
                    Text(workout.heading)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(workout.markedComplete ? AppTheme.textSecondary : AppTheme.textPrimary)
                        .strikethrough(workout.markedComplete, color: AppTheme.textMuted)
                }
                
                // Duration change
                HStack(spacing: 8) {
                    Text("\(workout.scheduledDuration)'")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textMuted)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.goldDark)
                    
                    Text("\(workout.adjustedDuration)'")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.goldPrimary)
                    
                    if let effort = workout.effortMarker {
                        Text("•")
                            .foregroundColor(AppTheme.textMuted)
                        
                        Text(effort)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Reduction indicator
            VStack(spacing: 2) {
                let reduction = Int(round(Double(workout.scheduledDuration - workout.adjustedDuration) / Double(workout.scheduledDuration) * 100))
                Text("–\(reduction)%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.goldPrimary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(workout.markedComplete ? AppTheme.successGreen.opacity(0.05) : AppTheme.surfaceDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            workout.markedComplete ? AppTheme.successGreen.opacity(0.2) : AppTheme.dividerTint,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Add Workout Sheet

struct AddWorkoutSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SpanViewModel
    
    @State private var selectedDay = 0
    @State private var title = "Easy Run"
    @State private var planMinutes: Double = 40
    @State private var intensityLabel = "Easy"
    @State private var note = ""
    
    private let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let intensityOptions = ["Easy", "Z2", "Tempo", "Intervals", "Strength", "Hills", "Mobility"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDeep
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(AppTheme.surfaceDark)
                                )
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        Text("Add Session")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 44, height: 32)
                            .padding(.trailing, 12)
                    }
                    .frame(height: 44)
                    .background(AppTheme.backgroundDeep)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Day selector
                            DaySelectorSection(
                                selectedDay: $selectedDay,
                                dayNames: dayNames
                            )
                            
                            // Details section
                            DetailsSection(
                                title: $title,
                                planMinutes: $planMinutes,
                                intensityLabel: $intensityLabel,
                                intensityOptions: intensityOptions
                            )
                            
                            // Note section
                            NoteSection(note: $note)
                            
                            // Preview
                            if let cycle = viewModel.currentCycle {
                                PreviewSection(
                                    planMinutes: Int(planMinutes),
                                    reductionRate: cycle.blueprint.reductionRate
                                )
                            }
                            
                            // Save button
                            Button(action: saveWorkout) {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                    
                                    Text("Add Session")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(AppTheme.backgroundDeep)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.goldGradient)
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(title.isEmpty || title.count < 2 || viewModel.currentCycle == nil)
                            .opacity(title.isEmpty || title.count < 2 ? 0.5 : 1)
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.currentCycle == nil {
                    viewModel.loadActiveCycle()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func saveWorkout() {
        guard let cycle = viewModel.currentCycle else { return }
        
        let reduction = Double(cycle.blueprint.reductionRate) / 100.0
        let reduced = max(10, Int(round(Double(planMinutes) * (1.0 - reduction))))
        
        let workout = WorkoutEntryModel(
            slotIndex: selectedDay,
            heading: title,
            scheduledDuration: Int(planMinutes),
            adjustedDuration: reduced,
            effortMarker: intensityLabel,
            easedEffortMarker: nil,
            markedComplete: false,
            memo: note.isEmpty ? nil : note
        )
        
        viewModel.addWorkout(workout)
        // Don't dismiss here - let the viewModel handle it after saving
    }
}

// MARK: - Day Selector Section

struct DaySelectorSection: View {
    @Binding var selectedDay: Int
    let dayNames: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Day", icon: "calendar")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(0..<7, id: \.self) { idx in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDay = idx
                        }
                    } label: {
                        Text(String(dayNames[idx].prefix(3)))
                            .font(.system(size: 14, weight: selectedDay == idx ? .bold : .medium))
                            .foregroundColor(selectedDay == idx ? AppTheme.backgroundDeep : AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedDay == idx ? AppTheme.goldGradient : LinearGradient(colors: [AppTheme.surfaceDark], startPoint: .leading, endPoint: .trailing))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedDay == idx ? .clear : AppTheme.dividerTint, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}

// MARK: - Details Section

struct DetailsSection: View {
    @Binding var title: String
    @Binding var planMinutes: Double
    @Binding var intensityLabel: String
    let intensityOptions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Details", icon: "pencil")
            
            VStack(spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Name")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    TextField("", text: $title)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.backgroundElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.dividerTint, lineWidth: 1)
                                )
                        )
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Duration")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Spacer()
                        
                        Text("\(Int(planMinutes)) min")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.goldPrimary)
                    }
                    
                    CustomSlider(value: $planMinutes, range: 5...180, step: 5)
                }
                
                // Intensity
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intensity")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(intensityOptions, id: \.self) { option in
                                Button {
                                    intensityLabel = option
                                } label: {
                                    Text(option)
                                        .font(.system(size: 13, weight: intensityLabel == option ? .semibold : .medium))
                                        .foregroundColor(intensityLabel == option ? AppTheme.backgroundDeep : AppTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(intensityLabel == option ? AppTheme.goldGradient : LinearGradient(colors: [AppTheme.surfaceDark], startPoint: .leading, endPoint: .trailing))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(intensityLabel == option ? .clear : AppTheme.dividerTint, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.surfaceDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.dividerTint, lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Note Section

struct NoteSection: View {
    @Binding var note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Note", icon: "text.alignleft")
            
            TextEditor(text: $note)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textPrimary)
                .frame(height: 80)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.surfaceDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.dividerTint, lineWidth: 1)
                        )
                )
        }
    }
}

// MARK: - Preview Section

struct PreviewSection: View {
    let planMinutes: Int
    let reductionRate: Int
    
    private var adjustedMinutes: Int {
        let reduction = Double(reductionRate) / 100.0
        return max(10, Int(round(Double(planMinutes) * (1.0 - reduction))))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundColor(AppTheme.goldPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
                
                HStack(spacing: 8) {
                    Text("\(planMinutes)'")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.goldDark)
                    
                    Text("\(adjustedMinutes)'")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.goldPrimary)
                    
                    Text("(–\(reductionRate)%)")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.goldPrimary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.goldDark.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Export Sheet View

struct ExportSheetView: View {
    @Environment(\.dismiss) var dismiss
    let cycle: SpanCycleModel?
    let workouts: [WorkoutEntryModel]
    let ringData: CycleTargetActualRingData?
    
    @State private var exportText = ""
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundDeep
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(AppTheme.surfaceDark)
                                )
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        Text("Export")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                        
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.goldPrimary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(AppTheme.goldPrimary.opacity(0.1))
                                )
                        }
                        .padding(.trailing, 12)
                    }
                    .frame(height: 44)
                    .background(AppTheme.backgroundDeep)
                    
                    ScrollView {
                        Text(exportText)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.surfaceDark)
                            )
                            .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: [exportText])
            }
            .onAppear {
                generateExport()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func generateExport() {
        guard let cycle = cycle else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let startStr = dateFormatter.string(from: cycle.kickoff)
        let endStr = dateFormatter.string(from: cycle.closure)
        
        var output = "═══════════════════════════════\n"
        output += "  JoGit:EndurancePlanner\n"
        output += "  Deload Week Report\n"
        output += "═══════════════════════════════\n\n"
        output += "📅 \(startStr) – \(endStr)\n"
        output += "📊 Rule: –\(cycle.blueprint.reductionRate)% (\(cycle.blueprint.cutbackStyle.displayName))\n\n"
        
        if let ringData = ringData {
            output += "─── Summary ───\n"
            output += "🎯 Target: –\(ringData.targetRate)%\n"
            output += "✓  Actual: –\(ringData.achievedRate)%\n"
            output += "📈 Status: \(ringData.verdictText)\n\n"
        }
        
        output += "─── Sessions ───\n"
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        var grouped: [Int: [WorkoutEntryModel]] = [:]
        for workout in workouts {
            grouped[workout.slotIndex, default: []].append(workout)
        }
        
        for idx in 0..<7 {
            if let dayWorkouts = grouped[idx], !dayWorkouts.isEmpty {
                output += "\n\(dayNames[idx]):\n"
                for workout in dayWorkouts {
                    let check = workout.markedComplete ? "✓" : "○"
                    output += "  \(check) \(workout.heading)\n"
                    output += "    \(workout.scheduledDuration)' → \(workout.adjustedDuration)'\n"
                }
            }
        }
        
        output += "\n═══════════════════════════════\n"
        
        exportText = output
    }
}

// MARK: - Press Events Modifier

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        AppTheme.goldPrimary.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 300
                    }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Activity View Controller (iOS 15 compatible share sheet)

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
