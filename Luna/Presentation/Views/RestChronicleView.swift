import SwiftUI

struct RestChronicleView: View {
    @ObservedObject var viewModel: RestChronicleViewModel
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    @State private var showAddManualEntry = false
    @State private var selectedCycle: RestCyclePrism?
    @State private var manualStartDate = Date()
    @State private var manualEndDate = Date()
    
    var body: some View {
        ZStack {
            LinearGradient.celestialBackdrop(isDark: nightModeActivated)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        orchestrator.navigateTo(.mainNexus)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(nightModeActivated))
                    }
                    
                    Spacer()
                    
                    Text("Sleep Diary")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptiveText(nightModeActivated))
                    
                    Spacer()
                    
                    Button(action: {
                        showAddManualEntry = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.adaptiveText(nightModeActivated))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.adaptiveCard(nightModeActivated))
                
                if viewModel.cyclePrisms.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 60))
                            .foregroundColor(Color.adaptiveSecondary(nightModeActivated))
                        
                        Text("No sleep records yet")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveText(nightModeActivated))
                        
                        Text("Add your first entry or sync with HealthKit")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            viewModel.showHealthKitPrompt = true
                            viewModel.requestHealthKitAccess()
                        }) {
                            Text("Connect HealthKit")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.pureEssence)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.adaptiveAccent(nightModeActivated))
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.cyclePrisms) { cycle in
                                Button(action: {
                                    selectedCycle = cycle
                                }) {
                                    SleepCycleRowView(cycle: cycle, isDark: nightModeActivated)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    NavigationTabButton(icon: "house.fill", title: "Home", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.mainNexus)
                    }
                    
                    NavigationTabButton(icon: "moon.fill", title: "Diary", isSelected: true, isDark: nightModeActivated) {
                    }
                    
                    NavigationTabButton(icon: "chart.bar.fill", title: "Stats", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.statistics)
                    }
                    
                    NavigationTabButton(icon: "gearshape.fill", title: "Settings", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.settings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.adaptiveCard(nightModeActivated).opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.adaptiveText(nightModeActivated).opacity(0.1), radius: 10, x: 0, y: -2)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .sheet(isPresented: $showAddManualEntry) {
            ManualSleepEntrySheet(
                startDate: $manualStartDate,
                endDate: $manualEndDate,
                onSave: { quality, comment in
                    viewModel.addManualCycle(start: manualStartDate, end: manualEndDate, quality: quality, comment: comment)
                    showAddManualEntry = false
                },
                onCancel: {
                    showAddManualEntry = false
                }
            )
        }
        .sheet(item: $selectedCycle) { cycle in
            SleepCycleDetailView(cycle: cycle, onDismiss: {
                selectedCycle = nil
            })
        }
        .navigationBarHidden(true)
    }
}

struct SleepCycleRowView: View {
    let cycle: RestCyclePrism
    let isDark: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(cycle.initiationMoment, style: .date)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.adaptiveText(isDark))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(Color.adaptiveText(isDark).opacity(0.6))
                        
                        Text(cycle.sleepTimeRange)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color.adaptiveText(isDark).opacity(0.7))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.adaptiveText(isDark).opacity(0.6))
                        
                        Text("\(Int(cycle.phaseDurationInMinutes / 60))h \(Int(cycle.phaseDurationInMinutes.truncatingRemainder(dividingBy: 60)))m")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveText(isDark))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    if !cycle.breathFlowLinks.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.system(size: 14))
                            Text("\(cycle.breathFlowLinks.count)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color.adaptiveAccent(isDark))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.adaptiveAccent(isDark).opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if let quality = cycle.qualityMetric {
                        HStack(spacing: 4) {
                            ForEach(0..<min(quality, 5), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.adaptiveAccent(isDark))
                            }
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.adaptiveText(isDark).opacity(0.3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            if let comment = cycle.commentNote, !comment.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                
                HStack {
                    Text(comment)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color.adaptiveText(isDark).opacity(0.7))
                        .lineLimit(2)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .background(Color.adaptiveCard(isDark))
        .cornerRadius(14)
        .shadow(color: Color.adaptiveSecondary(isDark).opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

struct SleepCycleDetailView: View {
    let cycle: RestCyclePrism
    let onDismiss: () -> Void
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.celestialBackdrop(isDark: nightModeActivated)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color.adaptiveAccent(nightModeActivated))
                            
                            Text(cycle.initiationMoment, style: .date)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            DetailRowView(
                                icon: "clock",
                                title: "Time Period",
                                value: cycle.sleepTimeRange,
                                isDark: nightModeActivated
                            )
                            
                            DetailRowView(
                                icon: "moon.fill",
                                title: "Duration",
                                value: "\(Int(cycle.phaseDurationInMinutes / 60))h \(Int(cycle.phaseDurationInMinutes.truncatingRemainder(dividingBy: 60)))m",
                                isDark: nightModeActivated
                            )
                            
                            if let quality = cycle.qualityMetric {
                                DetailRowView(
                                    icon: "star.fill",
                                    title: "Quality",
                                    value: "\(cycle.qualityDescription) (\(quality)/10)",
                                    isDark: nightModeActivated
                                )
                            }
                            
                            if !cycle.breathFlowLinks.isEmpty {
                                DetailRowView(
                                    icon: "wind",
                                    title: "Breathing Sessions",
                                    value: "\(cycle.breathFlowLinks.count) session\(cycle.breathFlowLinks.count == 1 ? "" : "s")",
                                    isDark: nightModeActivated
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if let comment = cycle.commentNote, !comment.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Notes")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                                
                                Text(comment)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.adaptiveCard(nightModeActivated).opacity(0.5))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Sleep Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(Color.adaptiveAccent(nightModeActivated))
                }
            }
        }
    }
}

struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String
    let isDark: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.adaptiveAccent(isDark))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveText(isDark).opacity(0.7))
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.adaptiveText(isDark))
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.pureEssence.opacity(0.5))
        .cornerRadius(12)
    }
}

struct ManualSleepEntrySheet: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onSave: (Int?, String?) -> Void
    let onCancel: () -> Void
    
    @State private var quality: Int = 5
    @State private var comment: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.celestialBackdrop
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Sleep Period")) {
                        DatePicker("Bedtime", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("Wake Time", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section(header: Text("Quality (Optional)")) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Rating: \(quality)/10")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                Spacer()
                            }
                            
                            Slider(value: Binding(
                                get: { Double(quality) },
                                set: { quality = Int($0) }
                            ), in: 1...10, step: 1)
                            .accentColor(.nebulaBlossom)
                        }
                    }
                    
                    Section(header: Text("Notes (Optional)")) {
                        TextEditor(text: $comment)
                            .frame(minHeight: 80)
                            .font(.system(size: 15, design: .rounded))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Sleep Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(quality, comment.isEmpty ? nil : comment)
                    }
                }
            }
        }
    }
}
