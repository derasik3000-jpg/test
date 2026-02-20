import SwiftUI

// MARK: - FirstLightOnboardingView
// Multi-page onboarding: explains app mechanics, gamification, and sets up first companion

struct FirstLightOnboardingView: View {

    let onComplete: () -> Void

    @State private var currentPage: Int = 0
    @State private var companionName: String = ""
    @State private var selectedSpecies: CreatureKind = .dog
    @State private var selectedEmoji: String = "🐾"
    @State private var pageTransition: Bool = false
    @State private var iconBounce: Bool = false
    @State private var glowPulse: Bool = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            EmberCanvasView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                skipBar

                // Page content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    trackingPage.tag(1)
                    gamificationPage.tag(2)
                    companionSetupPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Bottom controls
                bottomControls
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    // MARK: - Skip Bar

    private var skipBar: some View {
        HStack {
            Spacer()
            if currentPage < totalPages - 1 {
                Button("Skip") {
                    withAnimation { currentPage = totalPages - 1 }
                }
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }
        }
        .frame(height: 40)
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        OnboardingPageLayout(
            iconContent: {
                ZStack {
                    Circle()
                        .fill(AuraPalette.goldMist)
                        .frame(width: 140, height: 140)
                        .scaleEffect(glowPulse ? 1.1 : 0.95)

                    Text("🐾")
                        .font(.system(size: 72))
                        .scaleEffect(iconBounce ? 1.1 : 1.0)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.4).repeatForever(autoreverses: true)) {
                                iconBounce = true
                            }
                        }
                }
            },
            title: "Welcome to Pet Log: True Feel",
            subtitle: "Your companion's wellness journal.\nObserve patterns. Share with your vet.\nNo diagnoses — just clear facts.",
            highlight: "Simple. Calm. Helpful.",
            disclaimer: "This app is for observational tracking only. It does not provide medical advice, diagnosis, or treatment. Always consult a veterinarian for health concerns."
        )
    }

    // MARK: - Page 2: Tracking Explained

    private var trackingPage: some View {
        OnboardingPageLayout(
            iconContent: {
                VStack(spacing: 12) {
                    featureRow(icon: "slider.horizontal.3", text: "Rate 4 wellness scales daily", delay: 0.0)
                    featureRow(icon: "exclamationmark.bubble.fill", text: "Log symptom episodes instantly", delay: 0.2)
                    featureRow(icon: "chart.line.uptrend.xyaxis", text: "See trends over 7 / 14 / 30 days", delay: 0.4)
                    featureRow(icon: "doc.text.fill", text: "Export vet-ready reports", delay: 0.6)
                }
                .padding(.horizontal, 20)
            },
            title: "Track What Matters",
            subtitle: "Quick scales for appetite, digestion,\nenergy, and mood — plus symptom events\nwith severity and notes.",
            highlight: "1–2 taps. That's it."
        )
    }

    // MARK: - Page 3: Gamification

    private var gamificationPage: some View {
        OnboardingPageLayout(
            iconContent: {
                VStack(spacing: 16) {
                    // XP bar preview
                    xpBarPreview

                    // Badges preview
                    HStack(spacing: 16) {
                        badgePreview(emoji: "🏅", name: "First Step")
                        badgePreview(emoji: "🔥", name: "Week Warrior")
                        badgePreview(emoji: "⚡", name: "Ten Streak")
                    }
                }
                .padding(.horizontal, 20)
            },
            title: "Earn & Grow",
            subtitle: "Every log earns XP. Keep streaks alive.\nUnlock badges and level up\nfrom Novice Observer to Eternal Guardian.",
            highlight: "Your dedication is rewarded."
        )
    }

    // MARK: - Page 4: Companion Setup

    private var companionSetupPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Add Your Companion")
                .font(AuraFont.heroTitle())
                .foregroundColor(AuraPalette.boneWhite)
                .multilineTextAlignment(.center)

            // Emoji avatar display
            ZStack {
                Circle()
                    .fill(AuraPalette.goldMist)
                    .frame(width: 100, height: 100)
                    .scaleEffect(glowPulse ? 1.05 : 0.95)

                Text(selectedEmoji)
                    .font(.system(size: 52))
            }

            // Name field
            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)

                TextField("", text: $companionName)
                    .placeholder(when: companionName.isEmpty) {
                        Text("Your companion's name")
                            .foregroundColor(AuraPalette.whisperAsh)
                    }
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)
                    .padding(14)
                    .background(AuraPalette.healingCharcoal)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            // Species picker
            VStack(alignment: .leading, spacing: 6) {
                Text("Species")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)
                    .padding(.horizontal, 32)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(CreatureKind.allCases) { kind in
                            speciesChip(kind)
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }

            Spacer()
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? AuraPalette.lifeGold : AuraPalette.whisperAsh)
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4), value: currentPage)
                }
            }

            // Action button
            Button(action: handleNext) {
                Text(currentPage == totalPages - 1 ? "Begin Journey" : "Continue")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.restingNight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        currentPage == totalPages - 1 && companionName.trimmingCharacters(in: .whitespaces).isEmpty
                        ? AuraPalette.fadedElixir
                        : AuraPalette.lifeGold
                    )
                    .cornerRadius(16)
            }
            .disabled(currentPage == totalPages - 1 && companionName.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Sub-components

    private func featureRow(icon: String, text: String, delay: Double) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(AuraPalette.lifeGold)
                .frame(width: 36, height: 36)

            Text(text)
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.boneWhite)

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(AuraPalette.healingCharcoal.opacity(0.6))
        .cornerRadius(12)
    }

    private var xpBarPreview: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Level 1")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)
                Spacer()
                Text("25 / 50 XP")
                    .font(AuraFont.xpCounter())
                    .foregroundColor(AuraPalette.experienceGlow)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AuraPalette.healingCharcoal)

                    Capsule()
                        .fill(AuraPalette.goldAuraGradient)
                        .frame(width: geo.size.width * 0.5)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(AuraPalette.shelterSmoke.opacity(0.7))
        .cornerRadius(14)
    }

    private func badgePreview(emoji: String, name: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(AuraPalette.goldMist)
                    .frame(width: 52, height: 52)

                Text(emoji)
                    .font(.system(size: 28))
            }

            Text(name)
                .font(AuraFont.badgeStamp())
                .foregroundColor(AuraPalette.mistBreath)
                .lineLimit(1)
        }
    }

    private func speciesChip(_ kind: CreatureKind) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedSpecies = kind
                selectedEmoji = kind.icon
            }
        } label: {
            VStack(spacing: 4) {
                Text(kind.icon)
                    .font(.system(size: 28))
                Text(kind.displayName)
                    .font(AuraFont.badgeStamp())
                    .foregroundColor(
                        selectedSpecies == kind
                        ? AuraPalette.restingNight
                        : AuraPalette.mistBreath
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                selectedSpecies == kind
                ? AuraPalette.lifeGold
                : AuraPalette.healingCharcoal
            )
            .cornerRadius(12)
        }
    }

    // MARK: - Actions

    private func handleNext() {
        if currentPage < totalPages - 1 {
            withAnimation { currentPage += 1 }
        } else {
            createCompanionAndFinish()
        }
    }

    private func createCompanionAndFinish() {
        let trimmedName = companionName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let companion = CompanionProfile(
            name: trimmedName,
            species: selectedSpecies,
            avatarEmoji: selectedEmoji
        )
        GroveStorage.shared.saveCompanion(companion)
        GroveStorage.shared.completeOnboarding()
        onComplete()
    }
}

// MARK: - OnboardingPageLayout

private struct OnboardingPageLayout<IconContent: View>: View {

    let iconContent: () -> IconContent
    let title: String
    let subtitle: String
    let highlight: String
    var disclaimer: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            iconContent()
                .frame(minHeight: 180)

            VStack(spacing: 12) {
                Text(title)
                    .font(AuraFont.heroTitle())
                    .foregroundColor(AuraPalette.boneWhite)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AuraFont.bodyPulse())
                    .foregroundColor(AuraPalette.mistBreath)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text(highlight)
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.lifeGold)
                    .padding(.top, 4)

                if let disclaimer = disclaimer {
                    Text(disclaimer)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AuraPalette.whisperAsh)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Placeholder Modifier (iOS 16 compat)

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
