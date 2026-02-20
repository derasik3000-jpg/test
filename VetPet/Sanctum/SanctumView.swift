import SwiftUI

// MARK: - SanctumView
// Third tab: Avatar, Stats, Badges, Companions, Settings, Share

struct SanctumView: View {

    @ObservedObject var viewModel: SanctumViewModel
    @ObservedObject var coordinator: PathwayCoordinator

    @State private var animateIn: Bool = false
    @State private var showAvatarPicker: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var avatarBounce: Bool = false
    @State private var showAddScaleSheet: Bool = false
    @State private var showAddReminderKindSheet: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.sanctumPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile header with avatar
                    profileHeader

                    // Vitality card
                    vitalityCard

                    // Lifetime stats
                    statsGrid

                    // Badge showcase
                    badgeShowcase

                    // Companions
                    companionsSection

                    // Scales settings
                    scaleSettings

                    // Reminder categories
                    reminderCategoriesSection

                    // Insight toggle + range
                    observationSettings

                    // Share progress
                    shareSection

                    // Legal disclaimer
                    legalFooter

                    // Danger zone
                    dangerZone
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .withEmberBackdrop()
            .navigationTitle("Sanctum")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.refresh()
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    animateIn = true
                }
            }
            .sheet(isPresented: $showAvatarPicker) {
                avatarPickerSheet
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(text: viewModel.buildShareText())
            }
            .alert("Erase All Data?", isPresented: $viewModel.showPurgeConfirmation) {
                Button("Cancel", role: .cancel) { viewModel.cancelPurge() }
                Button("Erase Everything", role: .destructive) { viewModel.confirmPurge() }
            } message: {
                Text("This will permanently delete all companions, logs, episodes, badges, and progress. This cannot be undone.")
            }
            .alert("Remove Companion?", isPresented: $viewModel.showDeleteCompanionConfirmation) {
                Button("Cancel", role: .cancel) { viewModel.cancelDeleteCompanion() }
                Button("Remove", role: .destructive) { viewModel.confirmDeleteCompanion() }
            } message: {
                if let c = viewModel.companionToDelete {
                    Text("This will remove \(c.name) and all their logs and episodes. You can undo this within 5 seconds.")
                }
            }
            .navigationDestination(for: PathwayCoordinator.Waypoint.self) { waypoint in
                sanctumWaypointDestination(waypoint)
            }
        }
        .overlay(alignment: .bottom) { toastOverlay }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            // Avatar circle
            Button {
                showAvatarPicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(AuraPalette.goldMist)
                        .frame(width: 90, height: 90)

                    Circle()
                        .stroke(AuraPalette.lifeGold, lineWidth: 2.5)
                        .frame(width: 90, height: 90)
                        .scaleEffect(avatarBounce ? 1.08 : 1.0)

                    Text(viewModel.userAvatar)
                        .font(.system(size: 46))
                        .scaleEffect(avatarBounce ? 1.1 : 1.0)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    avatarBounce = true
                }
            }

            VStack(spacing: 4) {
                Text(viewModel.vitality.levelTitle)
                    .font(AuraFont.sectionHeadline())
                    .foregroundColor(AuraPalette.boneWhite)

                Text("Tap avatar to customize")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(.top, 8)
        .opacity(animateIn ? 1 : 0)
        .scaleEffect(animateIn ? 1 : 0.9)
    }

    // MARK: - Vitality Card

    private var vitalityCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(viewModel.vitality.currentLevel)")
                        .font(AuraFont.heroTitle())
                        .foregroundColor(AuraPalette.lifeGold)
                    Text(viewModel.vitality.levelTitle)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.vitality.totalXP) XP")
                        .font(AuraFont.xpCounter())
                        .foregroundColor(AuraPalette.experienceGlow)

                    if viewModel.vitality.currentStreak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AuraPalette.streakFlame)
                            Text("\(viewModel.vitality.currentStreak) day streak")
                                .font(AuraFont.badgeStamp())
                                .foregroundColor(AuraPalette.streakFlame)
                        }
                    }
                }
            }

            // XP bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AuraPalette.healingCharcoal)

                    Capsule()
                        .fill(AuraPalette.goldAuraGradient)
                        .frame(width: geo.size.width * CGFloat(viewModel.vitality.levelProgress))
                        .animation(.spring(response: 0.6), value: viewModel.vitality.levelProgress)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(viewModel.vitality.xpForCurrentLevel) XP")
                    .font(AuraFont.badgeStamp())
                    .foregroundColor(AuraPalette.whisperAsh)
                Spacer()
                Text("\(viewModel.vitality.xpForNextLevel) XP")
                    .font(AuraFont.badgeStamp())
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(16)
        .background(AuraPalette.shelterSmoke.opacity(0.7))
        .cornerRadius(16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Lifetime Stats", icon: "chart.bar.fill")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                statTile(
                    value: "\(viewModel.lifetimeStats.totalDaysLogged)",
                    label: "Days Logged",
                    icon: "calendar.badge.checkmark"
                )
                statTile(
                    value: "\(viewModel.lifetimeStats.totalEpisodes)",
                    label: "Episodes",
                    icon: "exclamationmark.bubble.fill"
                )
                statTile(
                    value: "\(viewModel.vitality.longestStreak)",
                    label: "Best Streak",
                    icon: "flame.fill"
                )
                statTile(
                    value: "\(viewModel.companions.count)",
                    label: "Companions",
                    icon: "pawprint.fill"
                )
            }

            // Axis averages
            if !viewModel.lifetimeStats.axisAverages.isEmpty {
                VStack(spacing: 8) {
                    ForEach(WellnessAxis.allCases) { axis in
                        if let avg = viewModel.lifetimeStats.axisAverages[axis] {
                            axisAverageRow(axis: axis, average: avg)
                        }
                    }
                }
                .padding(14)
                .background(AuraPalette.shelterSmoke.opacity(0.5))
                .cornerRadius(14)
            }

            // Extra facts
            if let topKind = viewModel.lifetimeStats.topEpisodeKind {
                factRow(
                    icon: topKind.icon,
                    text: "Most common: \(topKind.displayName) (×\(viewModel.lifetimeStats.topEpisodeCount))"
                )
            }

            if let companion = viewModel.lifetimeStats.mostActiveCompanion {
                factRow(icon: "star.fill", text: "Most tracked: \(companion)")
            }

            if viewModel.lifetimeStats.joinedDaysAgo > 0 {
                factRow(icon: "clock.fill", text: "Tracking for \(viewModel.lifetimeStats.joinedDaysAgo) days")
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }

    private func statTile(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AuraPalette.lifeGold)

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

    private func axisAverageRow(axis: WellnessAxis, average: Double) -> some View {
        HStack(spacing: 10) {
            Image(systemName: axis.icon)
                .font(.system(size: 13))
                .foregroundColor(AuraPalette.lifeGold)
                .frame(width: 20)

            Text(axis.displayName)
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.boneWhite)

            Spacer()

            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AuraPalette.healingCharcoal)

                    Capsule()
                        .fill(AuraPalette.lifeGold.opacity(0.6))
                        .frame(width: geo.size.width * CGFloat(average / 5.0))
                }
            }
            .frame(width: 80, height: 6)

            Text(String(format: "%.1f", average))
                .font(AuraFont.xpCounter())
                .foregroundColor(AuraPalette.mistBreath)
                .frame(width: 30, alignment: .trailing)
        }
    }

    private func factRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(AuraPalette.lifeGold)
                .frame(width: 20)
            Text(text)
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.mistBreath)
            Spacer()
        }
        .padding(12)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(12)
    }

    // MARK: - Badge Showcase

    private var badgeShowcase: some View {
        Button {
            coordinator.openPortal(.badgeShowcase)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AuraPalette.lifeGold)
                    .frame(width: 28, alignment: .center)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Badges")
                        .font(AuraFont.cardTitle())
                        .foregroundColor(AuraPalette.boneWhite)
                    Text("\(viewModel.badgeStates.filter(\.isUnlocked).count) of \(viewModel.badgeStates.count) unlocked")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }

    // MARK: - Companions Section

    private var companionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("Companions", icon: "pawprint.fill")
                Spacer()
                Button {
                    coordinator.openPortal(.addCompanion)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }

            if viewModel.companions.isEmpty {
                Text("No companions added yet")
                    .font(AuraFont.bodyPulse())
                    .foregroundColor(AuraPalette.whisperAsh)
                    .padding(14)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.companions) { companion in
                        companionRow(companion)
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
    }

    private func companionRow(_ companion: CompanionProfile) -> some View {
        HStack(spacing: 12) {
            Text(companion.avatarEmoji)
                .font(.system(size: 28))
                .frame(width: 40, height: 40)
                .background(AuraPalette.goldMist)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(companion.name)
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)

                Text(companion.species.displayName)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)
            }

            Spacer()

            Button {
                coordinator.openPortal(.editCompanion(companion.id))
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AuraPalette.mistBreath)
            }

            Button {
                viewModel.requestDeleteCompanion(companion)
            } label: {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AuraPalette.emberWarn.opacity(0.7))
            }
        }
        .padding(12)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Scale Settings

    private var scaleSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("Wellness Scales", icon: "slider.horizontal.3")
                Spacer()
                Button {
                    showAddScaleSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }

            VStack(spacing: 8) {
                ForEach(WellnessAxis.allCases) { axis in
                    HStack(spacing: 12) {
                        Image(systemName: axis.icon)
                            .font(.system(size: 14))
                            .foregroundColor(AuraPalette.lifeGold)
                            .frame(width: 22)

                        Text(axis.displayName)
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { viewModel.isAxisEnabled(axis) },
                            set: { _ in viewModel.toggleAxis(axis) }
                        ))
                        .tint(AuraPalette.lifeGold)
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }

                ForEach(viewModel.customWellnessAxes) { axis in
                    HStack(spacing: 12) {
                        Image(systemName: axis.icon)
                            .font(.system(size: 14))
                            .foregroundColor(AuraPalette.lifeGold)
                            .frame(width: 22)

                        Text(axis.name)
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { viewModel.isAxisEnabled(axis.rawValue) },
                            set: { _ in viewModel.toggleAxis(axis.rawValue) }
                        ))
                        .tint(AuraPalette.lifeGold)
                        .labelsHidden()

                        Button {
                            viewModel.removeCustomWellnessAxis(axis)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(AuraPalette.emberWarn)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
        .opacity(animateIn ? 1 : 0)
        .sheet(isPresented: $showAddScaleSheet) {
            AddCustomScaleSheet(
                onSave: { name, icon in
                    viewModel.addCustomWellnessAxis(name: name, icon: icon)
                    showAddScaleSheet = false
                },
                onCancel: { showAddScaleSheet = false }
            )
        }
    }

    // MARK: - Reminder Categories Section

    private var reminderCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("Reminder Categories", icon: "bell.badge.fill")
                Spacer()
                Button {
                    showAddReminderKindSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }

            Text("Categories shown in Add Reminder")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)

            VStack(spacing: 8) {
                ForEach(viewModel.customReminderKinds) { kind in
                    HStack(spacing: 12) {
                        Image(systemName: kind.icon)
                            .font(.system(size: 14))
                            .foregroundColor(AuraPalette.lifeGold)
                            .frame(width: 22)

                        Text(kind.name)
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)

                        Spacer()

                        Button {
                            viewModel.removeCustomReminderKind(kind)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(AuraPalette.emberWarn)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if viewModel.customReminderKinds.isEmpty {
                    Text("No custom categories yet")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.whisperAsh)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
        .opacity(animateIn ? 1 : 0)
        .sheet(isPresented: $showAddReminderKindSheet) {
            AddCustomReminderKindSheet(
                onSave: { name, icon in
                    viewModel.addCustomReminderKind(name: name, icon: icon)
                    showAddReminderKindSheet = false
                },
                onCancel: { showAddReminderKindSheet = false }
            )
        }
    }

    // MARK: - Observation Settings

    private var observationSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Observations", icon: "eye.fill")

            VStack(spacing: 12) {
                // Insights toggle
                HStack {
                    Text("Show insight cards")
                        .font(AuraFont.bodyPulse())
                        .foregroundColor(AuraPalette.boneWhite)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { viewModel.insightsEnabled },
                        set: { _ in viewModel.toggleInsights() }
                    ))
                    .tint(AuraPalette.lifeGold)
                    .labelsHidden()
                }

                // Default range
                HStack {
                    Text("Default range")
                        .font(AuraFont.bodyPulse())
                        .foregroundColor(AuraPalette.boneWhite)

                    Spacer()

                    HStack(spacing: 6) {
                        ForEach(ChronicleRange.allCases) { range in
                            Button {
                                viewModel.setDefaultRange(range.rawValue)
                            } label: {
                                Text(range.displayName)
                                    .font(AuraFont.badgeStamp())
                                    .foregroundColor(
                                        viewModel.defaultRangeDays == range.rawValue
                                        ? AuraPalette.restingNight
                                        : AuraPalette.mistBreath
                                    )
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        viewModel.defaultRangeDays == range.rawValue
                                        ? AuraPalette.lifeGold
                                        : AuraPalette.healingCharcoal
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Share Section

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Share", icon: "square.and.arrow.up.fill")

            Button {
                showShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                    Text("Share Your Progress")
                        .font(AuraFont.cardTitle())
                }
                .foregroundColor(AuraPalette.restingNight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AuraPalette.lifeGold)
                .cornerRadius(14)
            }
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Legal Footer

    private var legalFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Not Medical Advice")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.whisperAsh)

            Text("This app is for observational tracking only. It does not provide medical advice, diagnosis, or treatment. Always consult a veterinarian for health concerns.")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(AuraPalette.whisperAsh.opacity(0.9))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AuraPalette.healingCharcoal.opacity(0.5))
        .cornerRadius(12)
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Danger Zone", icon: "exclamationmark.triangle.fill")

            Button {
                viewModel.requestPurge()
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                    Text("Erase All Data")
                        .font(AuraFont.cardTitle())
                }
                .foregroundColor(AuraPalette.emberWarn)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AuraPalette.emberWarn.opacity(0.12))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AuraPalette.emberWarn.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Avatar Picker Sheet

    private var avatarPickerSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Current avatar preview
                    ZStack {
                        Circle()
                            .fill(AuraPalette.goldMist)
                            .frame(width: 80, height: 80)
                        Text(viewModel.userAvatar)
                            .font(.system(size: 42))
                    }
                    .padding(.top, 12)

                    // Categories
                    ForEach(0..<SpiritAvatarSet.collection.count, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(SpiritAvatarSet.sectionNames[section])
                                .font(AuraFont.captionWhisper())
                                .foregroundColor(AuraPalette.mistBreath)
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                                ForEach(SpiritAvatarSet.collection[section], id: \.self) { emoji in
                                    Button {
                                        viewModel.selectAvatar(emoji)
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 56, height: 56)
                                            .background(
                                                viewModel.userAvatar == emoji
                                                ? AuraPalette.lifeGold.opacity(0.3)
                                                : AuraPalette.healingCharcoal
                                            )
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(
                                                        viewModel.userAvatar == emoji
                                                        ? AuraPalette.lifeGold
                                                        : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showAvatarPicker = false }
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }
        }
    }

    // MARK: - Waypoint Destinations

    @ViewBuilder
    private func sanctumWaypointDestination(_ waypoint: PathwayCoordinator.Waypoint) -> some View {
        switch waypoint {
        case .trendDetail(let axis):
            TrendDetailPlaceholderView(axis: axis)
        case .trendDetailCustom(let axisId):
            TrendDetailCustomPlaceholderView(axisId: axisId)
        case .dayDetail(let key):
            DayDetailPlaceholderView(dateKey: key)
        case .episodeDetail(let id):
            EpisodeDetailPlaceholderView(episodeId: id)
        case .companionDetail(let id):
            CompanionDetailPlaceholderView(companionId: id)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AuraPalette.lifeGold)
                .font(.system(size: 14))
            Text(title)
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)
        }
    }

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if viewModel.showUndoCompanionToast, let text = viewModel.toastText {
            HStack(spacing: 12) {
                Text(text)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.boneWhite)
                Button("Undo") {
                    viewModel.undoCompanionDelete()
                }
                .font(AuraFont.cardTitle())
                .foregroundColor(AuraPalette.lifeGold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AuraPalette.healingCharcoal.opacity(0.95))
            .cornerRadius(20)
            .padding(.bottom, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.4), value: viewModel.showUndoCompanionToast)
        } else if let text = viewModel.toastText {
            Text(text)
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.boneWhite)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(AuraPalette.healingCharcoal.opacity(0.95))
                .cornerRadius(20)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4), value: viewModel.toastText)
        }
    }
}

// MARK: - ShareSheetView (UIKit wrapper)

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
