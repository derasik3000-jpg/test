import SwiftUI
import CoreData

struct EvubewEditSessionView: View {
    let session: AxemobSessionModel
    let onDismiss: () -> Void
    
    @StateObject private var axemobViewModel: EvubewNewSessionViewModel
    @Environment(\.dismiss) private var ehonohDismiss
    @ObservedObject var degubaThemeManager = CuqavuThemeManager.shared
    
    init(session: AxemobSessionModel, onDismiss: @escaping () -> Void) {
        self.session = session
        self.onDismiss = onDismiss
        
        let viewModel = EvubewNewSessionViewModel(defaultMood: session.mood)
        viewModel.cuqavuTitle = session.title
        viewModel.axemobSelectedType = session.type
        viewModel.degubaStartTime = session.startTime
        viewModel.evubewEndTime = session.endTime
        viewModel.ehonohEnergyLevel = Double(session.energyLevel)
        viewModel.axemobMood = Double(session.mood)
        viewModel.cuqavuNote = session.note ?? ""
        
        _axemobViewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок и кнопка Cancel
                        HStack {
                            Text("Edit Session")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                ehonohDismiss()
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        DegubaTitleInputSection(title: $axemobViewModel.cuqavuTitle)
                        
                        EvubewTypeSelectionSection(selectedType: $axemobViewModel.axemobSelectedType)
                        
                        EhonohTimePickerSection(
                            startTime: $axemobViewModel.degubaStartTime,
                            endTime: $axemobViewModel.evubewEndTime
                        )
                        
                        AxemobEnergySliderSection(energyLevel: $axemobViewModel.ehonohEnergyLevel)
                        
                        CuqavuMoodSliderSection(mood: $axemobViewModel.axemobMood)
                        
                        DegubaNoteInputSection(note: $axemobViewModel.cuqavuNote)
                        
                        Button(action: {
                            if cuqavuUpdateSession() {
                                onDismiss()
                                ehonohDismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                
                                Text("Update Session")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [degubaThemeManager.degubaCurrentTheme.evubewPrimary, degubaThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: degubaThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3), radius: 10, x: 0, y: 4)
                        }
                        .disabled(axemobViewModel.cuqavuTitle.isEmpty)
                        .opacity(axemobViewModel.cuqavuTitle.isEmpty ? 0.5 : 1.0)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func cuqavuUpdateSession() -> Bool {
        guard !axemobViewModel.cuqavuTitle.isEmpty else { return false }
        
        let context = DegubaPersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<EvubewProductivitySession> = EvubewProductivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            let sessions = try context.fetch(fetchRequest)
            if let sessionToUpdate = sessions.first {
                sessionToUpdate.title = axemobViewModel.cuqavuTitle
                sessionToUpdate.type = axemobViewModel.axemobSelectedType.rawValue
                sessionToUpdate.startTime = axemobViewModel.degubaStartTime
                sessionToUpdate.endTime = axemobViewModel.evubewEndTime
                sessionToUpdate.energyLevel = Int16(axemobViewModel.ehonohEnergyLevel)
                sessionToUpdate.mood = Int16(axemobViewModel.axemobMood)
                sessionToUpdate.note = axemobViewModel.cuqavuNote.isEmpty ? nil : axemobViewModel.cuqavuNote
                
                let duration = Int16(axemobViewModel.evubewEndTime.timeIntervalSince(axemobViewModel.degubaStartTime) / 60)
                sessionToUpdate.durationMin = duration
                
                try context.save()
                
                let calculateSummary = DegubaCalculateSummaryUseCase(context: context)
                _ = calculateSummary.evubewExecuteForDate(session.createdAt)
                
                NotificationCenter.default.post(name: NSNotification.Name("SessionsUpdated"), object: nil)
                
                return true
            }
        } catch {
            print("Error updating session: \(error)")
        }
        
        return false
    }
}

