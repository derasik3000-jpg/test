import SwiftUI

struct DegubaOnboardingView: View {
    @StateObject private var evubewViewModel = EhonohOnboardingViewModel()
    @Binding var cuqavuIsOnboardingComplete: Bool
    @ObservedObject var axemobThemeManager = CuqavuThemeManager.shared
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                if evubewViewModel.degubaCurrentStep == 0 {
                    EhonohWelcomeStepView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.9))
                        ))
                } else if evubewViewModel.degubaCurrentStep == 1 {
                    EhonohTimeUnitsStepView(selectedUnits: $evubewViewModel.cuqavuSelectedTimeUnits)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.9))
                        ))
                } else if evubewViewModel.degubaCurrentStep == 2 {
                    CuqavuHapticStepView(vibrationEnabled: $evubewViewModel.axemobVibrationEnabled)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.9)),
                            removal: .move(edge: .leading).combined(with: .opacity).combined(with: .scale(scale: 0.9))
                        ))
                }
                
                Spacer()
                
                // Индикаторы прогресса
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        ZStack {
                            Circle()
                                .fill(index == evubewViewModel.degubaCurrentStep ? axemobThemeManager.degubaCurrentTheme.evubewPrimary : axemobThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.2))
                                .frame(width: index == evubewViewModel.degubaCurrentStep ? 12 : 8, height: index == evubewViewModel.degubaCurrentStep ? 12 : 8)
                            
                            if index < evubewViewModel.degubaCurrentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .scaleEffect(index == evubewViewModel.degubaCurrentStep ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: evubewViewModel.degubaCurrentStep)
                    }
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 16) {
                    if evubewViewModel.degubaCurrentStep > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                evubewViewModel.evubewPreviousStep()
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(axemobThemeManager.degubaCurrentTheme.evubewPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    Color(red: 0.2, green: 0.2, blue: 0.22)
                                    LinearGradient(
                                        colors: [
                                            axemobThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.15),
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
                                    .stroke(axemobThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            if evubewViewModel.degubaCurrentStep < 2 {
                                evubewViewModel.degubaNextStep()
                            } else {
                                evubewViewModel.cuqavuCompleteOnboarding()
                                cuqavuIsOnboardingComplete = true
                            }
                        }
                    }) {
                        HStack {
                            Text(evubewViewModel.degubaCurrentStep < 2 ? "Next" : "Get Started")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            
                            if evubewViewModel.degubaCurrentStep < 2 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [axemobThemeManager.degubaCurrentTheme.evubewPrimary, axemobThemeManager.degubaCurrentTheme.cuqavuSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: axemobThemeManager.degubaCurrentTheme.evubewPrimary.opacity(0.4), radius: 15, x: 0, y: 5)
                        .scaleEffect(evubewViewModel.degubaCurrentStep == 2 ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3), value: evubewViewModel.degubaCurrentStep)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct EhonohWelcomeStepView: View {
    @State private var degubaAnimationProgress: CGFloat = 0
    @State private var evubewIconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                // Анимированная иконка
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3),
                                    CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(degubaAnimationProgress)
                        .opacity(Double(degubaAnimationProgress))
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .rotationEffect(.degrees(evubewIconRotation))
                        .scaleEffect(degubaAnimationProgress)
                        .opacity(Double(degubaAnimationProgress))
                        .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                
                VStack(spacing: 16) {
                    Text("Welcome to")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        .opacity(Double(degubaAnimationProgress))
                    
                    Text("Bhydro Vigor")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        .opacity(Double(degubaAnimationProgress))
                    
                    Text("Track your productivity and stay focused")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(Double(degubaAnimationProgress))
                }
            }
            
            // Статистика приложения
            VStack(spacing: 16) {
                HStack(spacing: 30) {
                    DegubaFeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track",
                        description: "Monitor your sessions"
                    )
                    
                    DegubaFeatureCard(
                        icon: "bolt.fill",
                        title: "Analyze",
                        description: "Understand patterns"
                    )
                    
                    DegubaFeatureCard(
                        icon: "star.fill",
                        title: "Improve",
                        description: "Boost productivity"
                    )
                }
                .padding(.horizontal, 30)
                .opacity(Double(degubaAnimationProgress))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                degubaAnimationProgress = 1.0
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                evubewIconRotation = 360
            }
        }
    }
}

struct DegubaFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    @State private var cuqavuPulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                .scaleEffect(cuqavuPulseScale)
                .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5), radius: 10, x: 0, y: 0)
            
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
            
            Text(description)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                Color(red: 0.2, green: 0.2, blue: 0.22)
                LinearGradient(
                    colors: [
                        CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.15),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                cuqavuPulseScale = 1.1
            }
        }
    }
}

struct EhonohTimeUnitsStepView: View {
    @Binding var selectedUnits: Int16
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Time Units")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("How would you like to track your time?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedUnits = 0
                    }
                }) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 32))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .frame(width: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minutes")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("Perfect for detailed tracking")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if selectedUnits == 0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            selectedUnits == 0 ? Color(red: 0.2, green: 0.2, blue: 0.22) : Color(red: 0.18, green: 0.18, blue: 0.20)
                            LinearGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(selectedUnits == 0 ? 0.25 : 0.1),
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
                                selectedUnits == 0 ?
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5) :
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2),
                                lineWidth: selectedUnits == 0 ? 2 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: selectedUnits == 0 ? 12 : 6, x: 0, y: selectedUnits == 0 ? 4 : 2)
                    .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(selectedUnits == 0 ? 0.3 : 0), radius: 8, x: 0, y: 2)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedUnits = 1
                    }
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 32))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            .frame(width: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hours")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("Great for longer sessions")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if selectedUnits == 1 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            selectedUnits == 1 ? Color(red: 0.2, green: 0.2, blue: 0.22) : Color(red: 0.18, green: 0.18, blue: 0.20)
                            LinearGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(selectedUnits == 1 ? 0.25 : 0.1),
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
                                selectedUnits == 1 ?
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5) :
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2),
                                lineWidth: selectedUnits == 1 ? 2 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: selectedUnits == 1 ? 12 : 6, x: 0, y: selectedUnits == 1 ? 4 : 2)
                    .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(selectedUnits == 1 ? 0.3 : 0), radius: 8, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

struct CuqavuHapticStepView: View {
    @Binding var vibrationEnabled: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "waveform.path")
                    .font(.system(size: 60))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Haptic Feedback")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                
                Text("Enable vibration for better interaction")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        vibrationEnabled.toggle()
                        if vibrationEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
                }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(vibrationEnabled ? 0.3 : 0.1),
                                            CuqavuThemeManager.shared.degubaCurrentTheme.cuqavuSecondary.opacity(vibrationEnabled ? 0.2 : 0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: vibrationEnabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 28))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Haptic Feedback")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("Feel tactile responses when interacting")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            vibrationEnabled ? Color(red: 0.2, green: 0.2, blue: 0.22) : Color(red: 0.18, green: 0.18, blue: 0.20)
                            LinearGradient(
                                colors: [
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(vibrationEnabled ? 0.25 : 0.1),
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
                                vibrationEnabled ?
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.5) :
                                CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2),
                                lineWidth: vibrationEnabled ? 2 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: vibrationEnabled ? 12 : 6, x: 0, y: vibrationEnabled ? 4 : 2)
                    .shadow(color: CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(vibrationEnabled ? 0.3 : 0), radius: 8, x: 0, y: 2)
                }
                
                Text("You can change this later in Settings")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.7))
            }
            .padding(.horizontal, 30)
        }
    }
}

