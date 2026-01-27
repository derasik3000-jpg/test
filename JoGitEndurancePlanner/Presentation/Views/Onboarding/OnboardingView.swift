import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage1(currentPage: $currentPage)
                    .tag(0)
                
                OnboardingPage2(currentPage: $currentPage)
                    .tag(1)
                
                OnboardingPage3(currentPage: $currentPage)
                    .tag(2)
                
                OnboardingWizard(onComplete: {
                    print("[ONBOARDING] 🎯 User completed onboarding wizard")
                    
                    // Small delay to ensure animation completes smoothly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            onComplete()
                        }
                    }
                })
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                HStack {
                    Spacer()
                    if currentPage < 3 {
                        Button("Skip") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage = 3
                            }
                        }
                        .font(.body.weight(.medium))
                        .foregroundColor(AppTheme.goldPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.goldPrimary.opacity(0.15))
                        )
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            print("[ONBOARDING] OnboardingView appeared - hasCompletedOnboarding in UserDefaults: \(completed)")
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.backgroundDeep,
                AppTheme.backgroundElevated,
                AppTheme.surfaceDark.opacity(0.5)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Page 1

struct OnboardingPage1: View {
    @Binding var currentPage: Int
    @State private var showContent = false
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(AppTheme.goldPrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }
            
            VStack(spacing: 16) {
                Text("JoGit:EndurancePlanner")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Mini-Deloads Keep Your Rhythm")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Regular micro-recovery periods every 3-5 weeks prevent chronic fatigue and keep you on track")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
            
            Button(action: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentPage = 1
                }
            }) {
                HStack(spacing: 12) {
                    Text("Next")
                        .font(.headline)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppTheme.backgroundDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(AppTheme.goldGradient)
                        .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 12, y: 6)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                iconScale = 1
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                iconRotation = 5
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Page 2

struct OnboardingPage2: View {
    @Binding var currentPage: Int
    @State private var showContent = false
    @State private var sliderOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(AppTheme.goldPrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showContent ? 1 : 0.5)
                    .offset(x: sliderOffset)
            }
            
            VStack(spacing: 16) {
                Text("One Rule, One Week")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Set a simple reduction rule")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Choose –20% volume or intensity for 7 days. Your sessions automatically adjust to the lighter load")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
            
            Button(action: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentPage = 2
                }
            }) {
                HStack(spacing: 12) {
                    Text("Next")
                        .font(.headline)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppTheme.backgroundDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(AppTheme.goldGradient)
                        .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 12, y: 6)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sliderOffset = 3
            }
        }
    }
}

// MARK: - Page 3

struct OnboardingPage3: View {
    @Binding var currentPage: Int
    @State private var showContent = false
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var showCheckmark = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(AppTheme.successGreen.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                Circle()
                    .stroke(AppTheme.successGreen.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)
                    .scaleEffect(showCheckmark ? 1.2 : 1)
                    .opacity(showCheckmark ? 0 : 1)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.successGreen.opacity(0.8), AppTheme.successGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(checkmarkScale)
            }
            
            VStack(spacing: 16) {
                Text("Check Off & Compare")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Track your progress")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.goldLight, AppTheme.goldPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Mark sessions complete and see how your actual reduction compares to your target")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
            
            Button(action: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentPage = 3
                }
            }) {
                HStack(spacing: 12) {
                    Text("Get Started")
                        .font(.headline)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppTheme.backgroundDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(AppTheme.goldGradient)
                        .shadow(color: AppTheme.goldPrimary.opacity(0.3), radius: 12, y: 6)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                checkmarkScale = 1
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 1).repeatForever(autoreverses: false).delay(0.3)) {
                showCheckmark = true
            }
        }
    }
}

// MARK: - Wizard

struct OnboardingWizard: View {
    let onComplete: () -> Void
    
    @State private var selectedRate = 20
    @State private var selectedStyle: CutbackStyle = .volume
    @State private var showingSampleSessions = false
    @State private var showContent = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Let's Set Up")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)
                    
                    Text("Create your first deload week")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)
                }
                .padding(.top, 40)
                
                // Reduction Rate Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "percent")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        Text("Reduction Rate")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Picker("Rate", selection: $selectedRate) {
                        Text("–15%").tag(15)
                        Text("–20%").tag(20)
                        Text("–25%").tag(25)
                    }
                    .pickerStyle(.segmented)
                    
                    Text(rateDescription)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.surfaceDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.goldDark.opacity(0.3), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Style Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.goldPrimary)
                        
                        Text("What to Reduce")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Picker("Style", selection: $selectedStyle) {
                        Text("Volume").tag(CutbackStyle.volume)
                        Text("Intensity").tag(CutbackStyle.intensity)
                    }
                    .pickerStyle(.segmented)
                    
                    Text(selectedStyle == .volume ? "Reduces training duration by \(selectedRate)%" : "Lowers effort level and reduces reps")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.surfaceDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.goldDark.opacity(0.3), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer(minLength: 20)
                
                // Sample sessions toggle
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingSampleSessions.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: showingSampleSessions ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(showingSampleSessions ? AppTheme.goldPrimary : AppTheme.textMuted)
                        
                        Text("Add 3 sample sessions")
                            .font(.body.weight(.medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(showingSampleSessions ? AppTheme.goldPrimary.opacity(0.1) : AppTheme.surfaceDark)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showingSampleSessions ? AppTheme.goldPrimary.opacity(0.5) : AppTheme.dividerTint, lineWidth: 1)
                            )
                    )
                }
                .opacity(showContent ? 1 : 0)
                
                // Get Started button
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Get Started")
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(AppTheme.backgroundDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(AppTheme.goldGradient)
                            .shadow(color: AppTheme.goldPrimary.opacity(0.4), radius: 16, y: 8)
                    )
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.9)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    private var rateDescription: String {
        switch selectedRate {
        case 15: return "Light recovery, maintain most fitness"
        case 20: return "Balanced recovery for most athletes"
        case 25: return "Deep recovery after intense training blocks"
        default: return ""
        }
    }
}
