import SwiftUI

struct EhonohSettingsView: View {
    @StateObject private var cuqavuViewModel = AxemobSettingsViewModel()
    @ObservedObject var axemobThemeManager = CuqavuThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Заголовок
                        HStack {
                            Text("Settings")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(axemobThemeManager.degubaCurrentTheme.evubewPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        EvubewTimeUnitsSection(
                            selectedUnits: $cuqavuViewModel.cuqavuTimeUnits,
                            onUnitsChange: { units in
                                cuqavuViewModel.ehonohUpdateTimeUnits(units)
                            }
                        )
                        .padding(.horizontal)
                        
                        AxemobVibrationSection(
                            vibrationEnabled: $cuqavuViewModel.evubewVibrationEnabled,
                            onVibrationChange: { enabled in
                                cuqavuViewModel.axemobUpdateVibration(enabled)
                            }
                        )
                        .padding(.horizontal)
                        
                        CuqavuDataSection(
                            onClearData: {
                                cuqavuViewModel.ehonohShowClearAlert = true
                            }
                        )
                        .padding(.horizontal)
                        
                        EhonohAboutSection()
                            .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .alert("Clear All Data", isPresented: $cuqavuViewModel.ehonohShowClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    cuqavuViewModel.degubaClearAllData()
                }
            } message: {
                Text("This will permanently delete all your sessions and summaries. This action cannot be undone.")
            }
        }
    }
}

struct EvubewTimeUnitsSection: View {
    @Binding var selectedUnits: Int16
    let onUnitsChange: (Int16) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Time Units")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedUnits = 0
                        onUnitsChange(0)
                    }
                }) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 20))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Minutes")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("Display time in minutes")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if selectedUnits == 0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        }
                    }
                    .padding(12)
                    .background(
                        selectedUnits == 0 ?
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.25) :
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.08)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedUnits == 0 ?
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5) :
                                Color.clear,
                                lineWidth: selectedUnits == 0 ? 2 : 0
                            )
                    )
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedUnits = 1
                        onUnitsChange(1)
                    }
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 20))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hours")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("Display time in hours")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if selectedUnits == 1 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        }
                    }
                    .padding(12)
                    .background(
                        selectedUnits == 1 ?
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.25) :
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.08)
                    )
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedUnits == 1 ?
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5) :
                                Color.clear,
                                lineWidth: selectedUnits == 1 ? 2 : 0
                            )
                    )
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct AxemobVibrationSection: View {
    @Binding var vibrationEnabled: Bool
    let onVibrationChange: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path")
                    .font(.system(size: 20))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Haptic Feedback")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Vibration")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    
                    Text("Feel tactile feedback when interacting")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                }
                
                Spacer()
                
                Toggle("", isOn: $vibrationEnabled)
                    .labelsHidden()
                    .tint(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    .onChange(of: vibrationEnabled) { newValue in
                        onVibrationChange(newValue)
                    }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct CuqavuDataSection: View {
    let onClearData: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Data Management")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            
            Button(action: onClearData) {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                        
                        Text("Delete all sessions and summaries")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.6))
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        Color.red.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.red.opacity(0.3),
                            Color.red.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: Color.red.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct EhonohAboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("About")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("App Name")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                    
                    Spacer()
                    
                    Text("Bhydro Vigor")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                Divider()
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                HStack {
                    Text("Version")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
                
                Divider()
                    .background(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3))
                
                HStack {
                    Text("Platform")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                    
                    Spacer()
                    
                    Text("iOS 15+")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 4)
        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

