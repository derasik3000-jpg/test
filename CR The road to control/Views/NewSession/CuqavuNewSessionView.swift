import SwiftUI

struct CuqavuNewSessionView: View {
    @StateObject private var axemobViewModel: EvubewNewSessionViewModel
    @Environment(\.dismiss) private var ehonohDismiss
    @ObservedObject var degubaThemeManager = CuqavuThemeManager.shared
    
    init(defaultMood: Int16 = 3) {
        _axemobViewModel = StateObject(wrappedValue: EvubewNewSessionViewModel(defaultMood: defaultMood))
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
                            Text("New Session")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                ehonohDismiss()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(degubaThemeManager.degubaCurrentTheme.evubewPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(degubaThemeManager.degubaCurrentTheme.degubaCardBackground)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
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
                        
                        if let error = axemobViewModel.axemobValidationError {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                if axemobViewModel.cuqavuSaveSession() {
                                    axemobViewModel.degubaShowResult = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                    
                                    Text("Save & Track")
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
                            .disabled(!axemobViewModel.degubaIsFormValid())
                            .opacity(axemobViewModel.degubaIsFormValid() ? 1.0 : 0.5)
                            
                            if let hint = axemobViewModel.ehonohGetValidationHint() {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                                    
                                    Text(hint)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $axemobViewModel.evubewCreatedSession) { session in
                EvubewResultView(
                    session: session,
                    onDismiss: {
                        axemobViewModel.degubaResetForm()
                        ehonohDismiss()
                    }
                )
            }
        }
    }
}

struct DegubaTitleInputSection: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Task Title", systemImage: "text.cursor")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            TextField("Enter task name", text: $title)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                .padding(16)
                .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                .cornerRadius(12)
                .accentColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
        }
        .padding(.horizontal)
    }
}

struct EvubewTypeSelectionSection: View {
    @Binding var selectedType: EhonohSessionType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Type", systemImage: "tag.fill")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(EhonohSessionType.allCases, id: \.rawValue) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedType = type
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: type.evubewIcon)
                                .font(.system(size: 28))
                                .foregroundColor(selectedType == type ? type.cuqavuColor : CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text(type.degubaTitle)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedType == type ? type.cuqavuColor : CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(selectedType == type ? type.cuqavuColor.opacity(0.15) : CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedType == type ? type.cuqavuColor : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct EhonohTimePickerSection: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    // Вычисляем начало и конец текущего дня
    private var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var endOfToday: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Time", systemImage: "clock.fill")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    DatePicker("", selection: Binding(
                        get: { startTime },
                        set: { newValue in
                            let calendar = Calendar.current
                            let today = Date()
                            // Сохраняем только время, дата всегда сегодня
                            let components = calendar.dateComponents([.hour, .minute], from: newValue)
                            if let todayWithTime = calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: today) {
                                startTime = todayWithTime
                                // Если endTime раньше startTime, обновляем endTime
                                if endTime <= startTime {
                                    endTime = calendar.date(byAdding: .minute, value: 30, to: startTime) ?? startTime
                                }
                            }
                        }
                    ), displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                }
                
                Divider()
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("End Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    DatePicker("", selection: Binding(
                        get: { endTime },
                        set: { newValue in
                            let calendar = Calendar.current
                            let today = Date()
                            // Сохраняем только время, дата всегда сегодня
                            let components = calendar.dateComponents([.hour, .minute], from: newValue)
                            if let todayWithTime = calendar.date(bySettingHour: components.hour ?? 23, minute: components.minute ?? 59, second: 59, of: today) {
                                endTime = todayWithTime
                                // Если endTime раньше или равно startTime, обновляем startTime
                                if endTime <= startTime {
                                    startTime = calendar.date(byAdding: .minute, value: -30, to: endTime) ?? endTime
                                }
                            }
                        }
                    ), displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                }
            }
            .padding(16)
            .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct AxemobEnergySliderSection: View {
    @Binding var energyLevel: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Energy Level", systemImage: "bolt.fill")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
                
                Text("\(Int(energyLevel))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            
            Slider(value: $energyLevel, in: 1...10, step: 1)
                .tint(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                .padding(.vertical, 8)
            
            HStack {
                Text("Low")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
                
                Text("High")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
        }
        .padding(16)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CuqavuMoodSliderSection: View {
    @Binding var mood: Double
    
    let degubaEmojis = ["😔", "😕", "😐", "🙂", "😊"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Mood", systemImage: "face.smiling")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Spacer()
                
                Text(degubaEmojis[Int(mood) - 1])
                    .font(.system(size: 32))
            }
            
            Slider(value: $mood, in: 1...5, step: 1)
                .tint(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                .padding(.vertical, 8)
        }
        .padding(16)
        .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct DegubaNoteInputSection: View {
    @Binding var note: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes (Optional)", systemImage: "note.text")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("Add notes...")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $note)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    .frame(height: 100)
                    .padding(4)
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
                    .cornerRadius(12)
                    .accentColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            .background(CuqavuThemeManager.shared.degubaCurrentTheme.degubaCardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

