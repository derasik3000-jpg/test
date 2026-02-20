import SwiftUI

// MARK: - Pet Log: True Feel

@main
struct PetLogTrueFeelApp: App {

    @StateObject private var coordinator = PathwayCoordinator()

    var body: some Scene {
        WindowGroup {
            GatekeeperRootView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - GatekeeperRootView
// Manages app lifecycle: Splash → Onboarding → Main

struct GatekeeperRootView: View {

    @EnvironmentObject var coordinator: PathwayCoordinator

    @State private var phase: LaunchPhase = .splash

    enum LaunchPhase {
        case splash
        case onboarding
        case home
    }

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                DawnGatewayView {
                    advanceFromSplash()
                }
                .transition(.opacity)

            case .onboarding:
                FirstLightOnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        phase = .home
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .opacity
                ))

            case .home:
                RealmTabShell()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
    }

    private func advanceFromSplash() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if coordinator.needsOnboarding {
                phase = .onboarding
            } else {
                phase = .home
            }
        }
    }
}

// MARK: - RealmTabShell
// Main TabView with three tabs + sheet routing

struct RealmTabShell: View {

    @EnvironmentObject var coordinator: PathwayCoordinator

    @StateObject private var pulseVM = PulseViewModel()
    @StateObject private var chronicleVM = ChronicleViewModel()
    @StateObject private var careVM = CareViewModel()
    @StateObject private var sanctumVM = SanctumViewModel()

    var body: some View {
        TabView(selection: $coordinator.activeRealm) {
            PulseView(viewModel: pulseVM, coordinator: coordinator)
                .tabItem {
                    Label(
                        PathwayCoordinator.Realm.pulse.tabTitle,
                        systemImage: PathwayCoordinator.Realm.pulse.tabIcon
                    )
                }
                .tag(PathwayCoordinator.Realm.pulse)

            ChronicleView(viewModel: chronicleVM, coordinator: coordinator)
                .tabItem {
                    Label(
                        PathwayCoordinator.Realm.chronicle.tabTitle,
                        systemImage: PathwayCoordinator.Realm.chronicle.tabIcon
                    )
                }
                .tag(PathwayCoordinator.Realm.chronicle)

            CareView(viewModel: careVM, coordinator: coordinator)
                .tabItem {
                    Label(
                        PathwayCoordinator.Realm.care.tabTitle,
                        systemImage: PathwayCoordinator.Realm.care.tabIcon
                    )
                }
                .tag(PathwayCoordinator.Realm.care)

            SanctumView(viewModel: sanctumVM, coordinator: coordinator)
                .tabItem {
                    Label(
                        PathwayCoordinator.Realm.sanctum.tabTitle,
                        systemImage: PathwayCoordinator.Realm.sanctum.tabIcon
                    )
                }
                .tag(PathwayCoordinator.Realm.sanctum)
        }
        .tint(AuraPalette.lifeGold)
        .task {
            _ = await ReminderNotificationScheduler.shared.requestAuthorizationIfNeeded()
            ReminderNotificationScheduler.shared.rescheduleAll()
        }
        .onAppear {
            configureTabBarAppearance()
            syncCompanionFocus()
        }
        .onChange(of: coordinator.activeRealm) { _ in
            refreshActiveTab()
        }
        .sheet(item: $coordinator.activePortal) { portal in
            portalDestination(portal)
        }
    }

    // MARK: - Portal Routing (Sheets)

    @ViewBuilder
    private func portalDestination(_ portal: PathwayCoordinator.Portal) -> some View {
        switch portal {
        case .addCompanion:
            CompanionForgeSheet(
                editingCompanion: nil,
                onDismiss: {
                    coordinator.closePortal()
                    refreshAllTabs()
                }
            )

        case .editCompanion(let id):
            let companion = GroveStorage.shared.companions.first { $0.id == id }
            CompanionForgeSheet(
                editingCompanion: companion,
                onDismiss: {
                    coordinator.closePortal()
                    refreshAllTabs()
                }
            )

        case .addEpisode(let companionId):
            EpisodeForgeSheet(
                companionId: companionId,
                onDismiss: {
                    coordinator.closePortal()
                    refreshAllTabs()
                }
            )

        case .addReminder(let companionId):
            CareReminderSheet(
                companionId: companionId,
                onDismiss: {
                    coordinator.closePortal()
                    refreshAllTabs()
                }
            )

        case .addVetVisit(let companionId):
            VetVisitSheet(
                companionId: companionId,
                onDismiss: {
                    coordinator.closePortal()
                    refreshAllTabs()
                }
            )

        case .editEpisode:
            Text("Edit Episode")
                .withEmberBackdrop()

        case .badgeShowcase:
            badgeShowcaseSheet

        case .avatarPicker:
            Text("Avatar Picker")
                .withEmberBackdrop()

        case .statsOverview:
            statsOverviewSheet

        case .shareProgress:
            ShareSheetView(text: sanctumVM.buildShareText())
        }
    }

    // MARK: - Badge Showcase Sheet

    private var badgeShowcaseSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Progress summary
                    VStack(spacing: 8) {
                        Text("🏆")
                            .font(.system(size: 48))

                        let unlocked = sanctumVM.badgeStates.filter(\.isUnlocked).count
                        Text("\(unlocked) of \(sanctumVM.badgeStates.count) Unlocked")
                            .font(AuraFont.sectionHeadline())
                            .foregroundColor(AuraPalette.boneWhite)
                    }
                    .padding(.top, 8)

                    // All badges
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ], spacing: 14) {
                        ForEach(sanctumVM.badgeStates) { state in
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            state.isUnlocked
                                            ? AuraPalette.goldMist
                                            : AuraPalette.healingCharcoal
                                        )
                                        .frame(width: 64, height: 64)

                                    if state.isUnlocked {
                                        Text(state.badge.icon)
                                            .font(.system(size: 32))
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(AuraPalette.whisperAsh)
                                    }
                                }

                                Text(state.badge.displayName)
                                    .font(AuraFont.cardTitle())
                                    .foregroundColor(
                                        state.isUnlocked
                                        ? AuraPalette.boneWhite
                                        : AuraPalette.whisperAsh
                                    )
                                    .lineLimit(1)

                                Text(state.badge.requirement)
                                    .font(AuraFont.captionWhisper())
                                    .foregroundColor(AuraPalette.whisperAsh)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 160)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AuraPalette.shelterSmoke.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                state.isUnlocked
                                                ? AuraPalette.lifeGold.opacity(0.4)
                                                : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Badge Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { coordinator.closePortal() }
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }
        }
    }

    // MARK: - Stats Overview Sheet

    private var statsOverviewSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // XP overview
                    VStack(spacing: 8) {
                        Text("⭐")
                            .font(.system(size: 48))
                        Text("Level \(sanctumVM.vitality.currentLevel)")
                            .font(AuraFont.heroTitle())
                            .foregroundColor(AuraPalette.lifeGold)
                        Text(sanctumVM.vitality.levelTitle)
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.mistBreath)
                    }
                    .padding(.top, 8)

                    // Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        overviewTile(value: "\(sanctumVM.vitality.totalXP)", label: "Total XP", icon: "✨")
                        overviewTile(value: "\(sanctumVM.vitality.currentStreak)", label: "Current Streak", icon: "🔥")
                        overviewTile(value: "\(sanctumVM.vitality.longestStreak)", label: "Best Streak", icon: "⚡")
                        overviewTile(value: "\(sanctumVM.vitality.totalLogs)", label: "Total Logs", icon: "📊")
                        overviewTile(value: "\(sanctumVM.vitality.totalEpisodes)", label: "Episodes", icon: "📋")
                        overviewTile(value: "\(sanctumVM.vitality.unlockedBadges.count)", label: "Badges", icon: "🏅")
                    }
                    .padding(.horizontal, 4)

                    // XP breakdown
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How to earn XP")
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)

                        xpRow(action: "Log any scale", xp: XPReward.dailyLog)
                        xpRow(action: "All 4 scales in a day", xp: XPReward.fullDayLog)
                        xpRow(action: "Report a symptom", xp: XPReward.symptomReport)
                        xpRow(action: "Add a note", xp: XPReward.noteAdded)
                        xpRow(action: "Streak bonus (per day)", xp: XPReward.streakBonus)
                        xpRow(action: "Unlock a badge", xp: XPReward.badgeUnlock)
                    }
                    .padding(16)
                    .background(AuraPalette.shelterSmoke.opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { coordinator.closePortal() }
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }
        }
    }

    private func overviewTile(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 24))
            Text(value)
                .font(AuraFont.streakDigit())
                .foregroundColor(AuraPalette.boneWhite)
            Text(label)
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    private func xpRow(action: String, xp: Int) -> some View {
        HStack {
            Text(action)
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.mistBreath)
            Spacer()
            Text("+\(xp) XP")
                .font(AuraFont.xpCounter())
                .foregroundColor(AuraPalette.experienceGlow)
        }
    }

    // MARK: - Tab Bar Appearance

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AuraPalette.restingNight)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(AuraPalette.whisperAsh)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AuraPalette.whisperAsh)]
        itemAppearance.selected.iconColor = UIColor(AuraPalette.lifeGold)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AuraPalette.lifeGold)]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: - Refresh Helpers

    private func syncCompanionFocus() {
        let companions = GroveStorage.shared.companions
        if coordinator.focusedCompanionId == nil {
            coordinator.focusedCompanionId = companions.first?.id
        } else if !companions.isEmpty,
                  let focused = coordinator.focusedCompanionId,
                  !companions.contains(where: { $0.id == focused }) {
            coordinator.focusedCompanionId = companions.first?.id
        }
    }

    private func refreshActiveTab() {
        switch coordinator.activeRealm {
        case .pulse:     pulseVM.refresh()
        case .chronicle: chronicleVM.refresh()
        case .care:      careVM.refresh()
        case .sanctum:   sanctumVM.refresh()
        }
    }

    private func refreshAllTabs() {
        pulseVM.refresh()
        chronicleVM.refresh()
        careVM.refresh()
        sanctumVM.refresh()
    }
}

// MARK: - CompanionForgeSheet
// Add or edit a companion

struct CompanionForgeSheet: View {

    let editingCompanion: CompanionProfile?
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var species: CreatureKind = .dog
    @State private var avatarEmoji: String = "🐾"
    @State private var birthText: String = ""
    @State private var weightText: String = ""
    @State private var quirksText: String = ""

    @FocusState private var isNameFocused: Bool

    var isEditing: Bool { editingCompanion != nil }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(AuraPalette.goldMist)
                            .frame(width: 80, height: 80)
                        Text(avatarEmoji)
                            .font(.system(size: 42))
                    }
                    .padding(.top, 8)

                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)

                        TextField("", text: $name)
                            .placeholder(when: name.isEmpty) {
                                Text("Companion's name")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)
                            .focused($isNameFocused)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    // Species
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Species")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(CreatureKind.allCases) { kind in
                                    Button {
                                        withAnimation(.spring(response: 0.25)) {
                                            species = kind
                                            avatarEmoji = kind.icon
                                        }
                                    } label: {
                                        VStack(spacing: 3) {
                                            Text(kind.icon)
                                                .font(.system(size: 24))
                                            Text(kind.displayName)
                                                .font(AuraFont.badgeStamp())
                                                .foregroundColor(
                                                    species == kind
                                                    ? AuraPalette.restingNight
                                                    : AuraPalette.mistBreath
                                                )
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            species == kind
                                            ? AuraPalette.lifeGold
                                            : AuraPalette.healingCharcoal
                                        )
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }

                    // Age
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Age (optional)")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)

                        TextField("", text: $birthText)
                            .placeholder(when: birthText.isEmpty) {
                                Text("e.g. 3 years or 2021-05-01")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    // Weight
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weight in kg (optional)")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)

                        TextField("", text: $weightText)
                            .placeholder(when: weightText.isEmpty) {
                                Text("e.g. 12.5")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)
                            .keyboardType(.decimalPad)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    // Quirks / notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (allergies, diet, etc.)")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)

                        TextField("", text: $quirksText, axis: .vertical)
                            .placeholder(when: quirksText.isEmpty) {
                                Text("Comma-separated notes…")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)
                            .lineLimit(2...4)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Companion" : "New Companion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(AuraPalette.mistBreath)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCompanion() }
                        .font(AuraFont.cardTitle())
                        .foregroundColor(
                            name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? AuraPalette.whisperAsh
                            : AuraPalette.lifeGold
                        )
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let companion = editingCompanion else { return }
        name = companion.name
        species = companion.species
        avatarEmoji = companion.avatarEmoji
        birthText = companion.birthText
        weightText = companion.weightKg.map { String($0) } ?? ""
        quirksText = companion.quirks.joined(separator: ", ")
    }

    private func saveCompanion() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let quirks = quirksText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let companion = CompanionProfile(
            id: editingCompanion?.id ?? UUID(),
            name: trimmedName,
            species: species,
            birthText: birthText.trimmingCharacters(in: .whitespaces),
            weightKg: Double(weightText),
            quirks: quirks,
            avatarEmoji: avatarEmoji,
            createdAt: editingCompanion?.createdAt ?? Date()
        )

        GroveStorage.shared.saveCompanion(companion)
        onDismiss()
    }
}

// MARK: - Waypoint Hashable Conformance

extension PathwayCoordinator.Waypoint: Equatable {
    static func == (lhs: PathwayCoordinator.Waypoint, rhs: PathwayCoordinator.Waypoint) -> Bool {
        switch (lhs, rhs) {
        case (.trendDetail(let a), .trendDetail(let b)):         return a == b
        case (.trendDetailCustom(let a), .trendDetailCustom(let b)): return a == b
        case (.dayDetail(let a), .dayDetail(let b)):             return a == b
        case (.episodeDetail(let a), .episodeDetail(let b)):     return a == b
        case (.companionDetail(let a), .companionDetail(let b)): return a == b
        default: return false
        }
    }
}
