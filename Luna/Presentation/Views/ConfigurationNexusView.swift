import SwiftUI

struct ConfigurationNexusView: View {
    @ObservedObject var viewModel: ConfigurationNexusViewModel
    @ObservedObject var orchestrator: CelestialNavigationOrchestrator
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    @State private var showAddReminder = false
    @State private var newReminderTime = Date()
    
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
                    
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptiveText(nightModeActivated))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.adaptiveCard(nightModeActivated))
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Data & Privacy")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsToggleRow(
                                    title: "HealthKit Sync",
                                    description: "Import sleep data",
                                    isOn: Binding(
                                        get: { viewModel.configuration.healthDataSyncEnabled },
                                        set: { _ in viewModel.toggleHealthKitSync() }
                                    )
                                )
                            }
                            .background(Color.adaptiveCard(nightModeActivated))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Appearance")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsToggleRow(
                                    title: "Night Mode",
                                    description: "Darker color theme",
                                    isOn: Binding(
                                        get: { viewModel.configuration.nightModeActivated },
                                        set: { _ in viewModel.toggleNightMode() }
                                    )
                                )
                            }
                            .background(Color.adaptiveCard(nightModeActivated))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Sound")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Volume")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.adaptiveText(nightModeActivated))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(viewModel.configuration.amplitudeLevel * 100))%")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                                        .frame(width: 40, alignment: .trailing)
                                    
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.configuration.amplitudeLevel },
                                            set: { viewModel.adjustAmplitude($0) }
                                        ),
                                        in: 0...1
                                    )
                                    .frame(width: 120)
                                    .accentColor(Color.adaptiveAccent(nightModeActivated))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .background(Color.adaptiveCard(nightModeActivated))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Animation")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Intensity")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.adaptiveText(nightModeActivated))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(viewModel.configuration.animationIntensity * 100))%")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                                        .frame(width: 40, alignment: .trailing)
                                    
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.configuration.animationIntensity },
                                            set: { viewModel.adjustAnimationIntensity($0) }
                                        ),
                                        in: 0.5...1.5
                                    )
                                    .frame(width: 120)
                                    .accentColor(Color.adaptiveAccent(nightModeActivated))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .background(Color.adaptiveCard(nightModeActivated))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Reminders")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                                
                                Spacer()
                                
                                Button(action: {
                                    showAddReminder = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.adaptiveAccent(nightModeActivated))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if viewModel.configuration.reminderTimestamps.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.adaptiveSecondary(nightModeActivated).opacity(0.5))
                                    
                                    Text("No reminders set")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.adaptiveCard(nightModeActivated).opacity(0.5))
                                .cornerRadius(14)
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(viewModel.configuration.reminderTimestamps.enumerated()), id: \.offset) { index, time in
                                        HStack {
                                            Image(systemName: "bell.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color.adaptiveAccent(nightModeActivated))
                                            
                                            Text(time, style: .time)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                viewModel.removeReminderTimestamp(at: index)
                                            }) {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.5))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.adaptiveCard(nightModeActivated))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.adaptiveText(nightModeActivated))
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                SettingsInfoRow(title: "Version", value: "1.0.0", isDark: nightModeActivated)
                                SettingsInfoRow(title: "Data Storage", value: "Local Only", isDark: nightModeActivated)
                            }
                            .background(Color.adaptiveCard(nightModeActivated))
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    NavigationTabButton(icon: "house.fill", title: "Home", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.mainNexus)
                    }
                    
                    NavigationTabButton(icon: "moon.fill", title: "Diary", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.sleepDiary)
                    }
                    
                    NavigationTabButton(icon: "chart.bar.fill", title: "Stats", isSelected: false, isDark: nightModeActivated) {
                        orchestrator.navigateTo(.statistics)
                    }
                    
                    NavigationTabButton(icon: "gearshape.fill", title: "Settings", isSelected: true, isDark: nightModeActivated) {
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
        .sheet(isPresented: $showAddReminder) {
            ReminderTimePickerSheet(
                selectedTime: $newReminderTime,
                onSave: {
                    viewModel.addReminderTimestamp(newReminderTime)
                    showAddReminder = false
                },
                onCancel: {
                    showAddReminder = false
                }
            )
        }
        .alert("HealthKit Access", isPresented: $viewModel.showHealthKitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enable HealthKit access in Settings")
        }
        .navigationBarHidden(true)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveText(nightModeActivated))
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.adaptiveText(nightModeActivated).opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.nebulaBlossom)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    let isDark: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color.adaptiveText(isDark))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.adaptiveText(isDark).opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct ReminderTimePickerSheet: View {
    @Binding var selectedTime: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.celestialBackdrop
                    .ignoresSafeArea()
                
                VStack {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                }
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

