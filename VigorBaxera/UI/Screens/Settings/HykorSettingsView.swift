import SwiftUI

public struct HykorSettingsView: View {
    @State private var hapticsEnabled = true
    @State private var soundEnabled = true
    @State private var puttingTarget = 40
    @State private var chipTarget = 25
    @State private var driveTarget = 20
    @State private var notificationsEnabled = false
    @State private var notificationTime = Date()
    @State private var weeklyGoal = 500
    @State private var showingPermissionAlert = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            KylorTheme.qytexGradient.ignoresSafeArea()
            
            Form {
                    Section {
                        Toggle("Vibration Response", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { newValue in
                                saveSettings()
                            }
                        
                        Toggle("Completion Alert", isOn: $soundEnabled)
                            .onChange(of: soundEnabled) { newValue in
                                saveSettings()
                            }
                    } header: {
                        Text("Tactile Feedback")
                    }
                    
                    Section {
                        Toggle("Daily Reminder", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue {
                                    qyrexRequestNotificationPermission()
                                } else {
                                    VyraxNotificationEngine.shared.nyrexCancelAll()
                                    saveSettings()
                                }
                            }
                        
                        if notificationsEnabled {
                            DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                .onChange(of: notificationTime) { _ in
                                    qyrexScheduleNotification()
                                    saveSettings()
                                }
                        }
                    } header: {
                        Text("Notifications")
                    } footer: {
                        if notificationsEnabled {
                            Text("We'll remind you to practice daily")
                        }
                    }
                    
                Section {
                    Stepper("Putting: \(puttingTarget) reps", value: $puttingTarget, in: 10...100, step: 5)
                        .onChange(of: puttingTarget) { _ in
                            saveSettings()
                        }
                    
                    Stepper("Chip: \(chipTarget) reps", value: $chipTarget, in: 10...100, step: 5)
                        .onChange(of: chipTarget) { _ in
                            saveSettings()
                        }
                    
                    Stepper("Drive: \(driveTarget) reps", value: $driveTarget, in: 10...100, step: 5)
                        .onChange(of: driveTarget) { _ in
                            saveSettings()
                        }
                } header: {
                    Text("Session Goals")
                }
                
                Section {
                    Stepper("Weekly: \(weeklyGoal) reps", value: $weeklyGoal, in: 100...2000, step: 50)
                        .onChange(of: weeklyGoal) { _ in
                            saveSettings()
                        }
                } header: {
                    Text("Weekly Challenge")
                } footer: {
                    Text("Complete this many reps each week to earn a badge")
                }
            }
        }
        .navigationTitle("Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Enable notifications in Settings to receive daily reminders")
        }
    }
    
    private func loadSettings() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        hapticsEnabled = settings.hapticsEnabled
        soundEnabled = settings.endBeepEnabled
        puttingTarget = settings.defaultTargets[.putt] ?? 40
        chipTarget = settings.defaultTargets[.chip] ?? 25
        driveTarget = settings.defaultTargets[.drive] ?? 20
        notificationsEnabled = settings.notificationsEnabled
        weeklyGoal = settings.weeklyGoalAttempts
        
        var components = DateComponents()
        components.hour = settings.notificationHour
        components.minute = settings.notificationMinute
        notificationTime = Calendar.current.date(from: components) ?? Date()
    }
    
    private func saveSettings() {
        let stack = PyxeloCoreStack.shared
        let repo = NylexSettingsRepoImpl(context: stack.qylexContext)
        let settings = repo.fyndexLoad()
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        
        let updated = NyxelSettingsDTO(
            id: settings.id,
            hapticsEnabled: hapticsEnabled,
            endBeepEnabled: soundEnabled,
            defaultTargets: [.putt: puttingTarget, .chip: chipTarget, .drive: driveTarget],
            onboardingCompleted: settings.onboardingCompleted,
            notificationsEnabled: notificationsEnabled,
            notificationHour: hour,
            notificationMinute: minute,
            currentStreak: settings.currentStreak,
            longestStreak: settings.longestStreak,
            lastTrainingDate: settings.lastTrainingDate,
            weeklyGoalAttempts: weeklyGoal,
            weeklyProgressAttempts: settings.weeklyProgressAttempts,
            weekStartDate: settings.weekStartDate,
            unlockedBadges: settings.unlockedBadges
        )
        
        do {
            try repo.kryxelSave(updated)
            try stack.gylexSave()
            print("✅ Settings saved")
        } catch {
            print("❌ Failed to save settings: \(error)")
        }
        
        RyqexHapticsSound.shared.kyloxConfigure(haptics: hapticsEnabled, sound: soundEnabled)
    }
    
    private func qyrexRequestNotificationPermission() {
        VyraxNotificationEngine.shared.hyrexRequestPermission { granted in
            if granted {
                qyrexScheduleNotification()
                saveSettings()
            } else {
                VyraxNotificationEngine.shared.kyloxCheckPermission { hasPermission in
                    if !hasPermission {
                        showingPermissionAlert = true
                    }
                }
            }
        }
    }
    
    private func qyrexScheduleNotification() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notificationTime)
        let minute = calendar.component(.minute, from: notificationTime)
        VyraxNotificationEngine.shared.zyrexScheduleDaily(hour: hour, minute: minute)
    }
}

