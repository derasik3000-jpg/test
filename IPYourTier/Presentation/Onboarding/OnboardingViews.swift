import SwiftUI
import CoreData
import Combine

public class OnboardingFlowVM: ObservableObject {
    @Published public var currentPage: Int = 0
    private let settingsRepo: SettingsRepository
    
    public init(settingsRepo: SettingsRepository) {
        self.settingsRepo = settingsRepo
    }
    
    public func resolveOnboarding() {
        // Save to UserDefaults directly for reliability
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.synchronize()
        print("✅ Onboarding completed and saved")
        
        // Also save to CoreData
        var settings = settingsRepo.load()
        settings.onboardingShown = true
        settingsRepo.save(settings)
    }
    
    public func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            var settings = self.settingsRepo.load()
            settings.notificationsAllowedCached = granted
            self.settingsRepo.save(settings)
        }
    }
}

// MARK: - Main Container

public struct WelcomeFlowContainer: View {
    @StateObject private var viewModel: OnboardingFlowVM
    @Binding var isPresented: Bool
    
    public init(viewModel: OnboardingFlowVM, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            // Animated background
            OnboardingBackground(currentPage: viewModel.currentPage)
            
            VStack(spacing: 0) {
                // Custom page indicator
                OnboardingPageIndicator(currentPage: viewModel.currentPage, totalPages: 3)
                    .padding(.top, 60)
                
                TabView(selection: $viewModel.currentPage) {
                    IntroductionPanel(onNext: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            viewModel.currentPage = 1
                        }
                    })
                    .tag(0)
                    
                    FeatureHighlightPanel(onNext: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            viewModel.currentPage = 2
                        }
                    })
                    .tag(1)
                    
                    PermissionRequestPanel(
                        onRequestNotifications: {
                            viewModel.requestNotifications()
                        },
                        onComplete: {
                            viewModel.resolveOnboarding()
                            withAnimation(.easeOut(duration: 0.3)) {
                                isPresented = false
                            }
                        },
                        onSkip: {
                            viewModel.resolveOnboarding()
                            withAnimation(.easeOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated Background

struct OnboardingBackground: View {
    let currentPage: Int
    @State private var animateGradient = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    ThemeColorsConfig.backgroundDeep,
                    ThemeColorsConfig.backgroundCard,
                    ThemeColorsConfig.backgroundDeep
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            
            // Floating orbs
            GeometryReader { geo in
                Circle()
                    .fill(ThemeColorsConfig.accentBright.opacity(0.08))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: -50 + floatingOffset * 0.3,
                        y: 100 + sin(floatingOffset * 0.01) * 30
                    )
                
                Circle()
                    .fill(ThemeColorsConfig.accentWarm.opacity(0.06))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(
                        x: geo.size.width - 100,
                        y: geo.size.height - 300 + cos(floatingOffset * 0.01) * 20
                    )
                
                Circle()
                    .fill(ThemeColorsConfig.accentBright.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: geo.size.width * 0.5,
                        y: geo.size.height * 0.3 + sin(floatingOffset * 0.008) * 25
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                floatingOffset = 1000
            }
        }
    }
}

// MARK: - Page Indicator

struct OnboardingPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? ThemeColorsConfig.accentBright : ThemeColorsConfig.neutralAxis.opacity(0.4))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

// MARK: - Introduction Panel

struct IntroductionPanel: View {
    let onNext: () -> Void
    @State private var appeared = false
    @State private var iconPulse = false
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Animated icon
            ZStack {
                // Glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(ThemeColorsConfig.accentBright.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                        .frame(width: CGFloat(120 + i * 30), height: CGFloat(120 + i * 30))
                        .scaleEffect(iconPulse ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                            value: iconPulse
                        )
                }
                
                // Icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeColorsConfig.accentBright.opacity(0.2),
                                ThemeColorsConfig.accentBright.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ThemeColorsConfig.accentBright, ThemeColorsConfig.accentBright.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.5)
            
            // Title & subtitle
            VStack(spacing: 12) {
                Text("Welcome to Quick Check")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                
                Text("Fast symptom assessment to help distinguish fatigue from injury risk")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
            }
            
            // Disclaimer card
            DisclaimerCard()
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            
            Spacer()
            
            // Button
            OnboardingButton(title: "Get Started", style: .primary, action: onNext)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
            iconPulse = true
        }
    }
}

// MARK: - Disclaimer Card

struct DisclaimerCard: View {
    @State private var shimmer = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(ThemeColorsConfig.accentWarm)
                
                Text("Medical Disclaimer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentWarm)
            }
            
            Text("This app is not a substitute for professional medical advice. Always consult your physician with health concerns.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColorsConfig.accentWarm.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeColorsConfig.accentWarm.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Feature Highlight Panel

struct FeatureHighlightPanel: View {
    let onNext: () -> Void
    @State private var appeared = false
    @State private var stepsAppeared = [false, false, false]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("How It Works")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            
            VStack(spacing: 20) {
                OnboardingStepRow(
                    stepNumber: 1,
                    icon: "list.clipboard.fill",
                    title: "Answer Questions",
                    description: "6-9 quick questions about your symptoms",
                    isVisible: stepsAppeared[0]
                )
                
                OnboardingStepRow(
                    stepNumber: 2,
                    icon: "gauge.high",
                    title: "Get Risk Level",
                    description: "Low, Moderate, High, or Red Flag assessment",
                    isVisible: stepsAppeared[1]
                )
                
                OnboardingStepRow(
                    stepNumber: 3,
                    icon: "checkmark.shield.fill",
                    title: "Follow Plan",
                    description: "Today's action steps and when to recheck",
                    isVisible: stepsAppeared[2]
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            OnboardingButton(title: "Continue", style: .primary, action: onNext)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
            
            for i in 0..<3 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2 + Double(i) * 0.15)) {
                    stepsAppeared[i] = true
                }
            }
        }
    }
}

// MARK: - Step Row

struct OnboardingStepRow: View {
    let stepNumber: Int
    let icon: String
    let title: String
    let description: String
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Animated icon container
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeColorsConfig.accentBright.opacity(0.2),
                                ThemeColorsConfig.accentBright.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(ThemeColorsConfig.accentBright)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColorsConfig.backgroundCard.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
    }
}

// MARK: - Permission Panel

struct PermissionRequestPanel: View {
    let onRequestNotifications: () -> Void
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @State private var appeared = false
    @State private var bellRing = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated bell
            ZStack {
                // Notification waves
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(ThemeColorsConfig.accentBright.opacity(bellRing ? 0 : 0.3), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(bellRing ? 2 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.5),
                            value: bellRing
                        )
                }
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright.opacity(0.2),
                                    ThemeColorsConfig.accentBright.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [ThemeColorsConfig.accentBright, ThemeColorsConfig.accentBright.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(bellRing ? 5 : -5))
                        .animation(
                            .easeInOut(duration: 0.15)
                            .repeatCount(6, autoreverses: true)
                            .delay(0.5),
                            value: bellRing
                        )
                }
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.5)
            
            VStack(spacing: 12) {
                Text("Stay on Track")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Get gentle reminders to recheck your symptoms and stay informed about your health")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            
            // Features list
            VStack(spacing: 12) {
                NotificationFeatureRow(icon: "clock.fill", text: "Timely recheck reminders")
                NotificationFeatureRow(icon: "hand.raised.fill", text: "No spam, just health updates")
                NotificationFeatureRow(icon: "gear", text: "Fully customizable")
            }
            .padding(.horizontal, 40)
            .opacity(appeared ? 1 : 0)
            
            Spacer()
            
            VStack(spacing: 12) {
                OnboardingButton(title: "Enable Reminders", style: .primary) {
                    onRequestNotifications()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
                
                OnboardingButton(title: "Maybe Later", style: .secondary, action: onSkip)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bellRing = true
            }
        }
    }
}

struct NotificationFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeColorsConfig.accentBright)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.8))
            
            Spacer()
        }
    }
}

// MARK: - Button Styles

struct OnboardingButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary, secondary
    }
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(style == .primary ? ThemeColorsConfig.backgroundDeep : ThemeColorsConfig.primaryLight)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if style == .primary {
                            LinearGradient(
                                colors: [
                                    ThemeColorsConfig.accentBright,
                                    ThemeColorsConfig.accentBright.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            ThemeColorsConfig.neutralMuted.opacity(0.3)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            style == .primary ? Color.clear : ThemeColorsConfig.neutralAxis.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
        }
    }
}
