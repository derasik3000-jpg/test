import SwiftUI

// MARK: - PulseView
// Main dashboard tab: vitality bar, quick scales, trends, insights

struct PulseView: View {

    @ObservedObject var viewModel: PulseViewModel
    @ObservedObject var coordinator: PathwayCoordinator

    @State private var animateCards: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.pulsePath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Companion selector
                    companionStrip

                    if viewModel.isEmptyState && viewModel.activeCompanion != nil {
                        emptyPrompt
                    } else if viewModel.activeCompanion != nil {
                        // XP & Level bar
                        vitalityBanner

                        // Quick scales
                        scalesSection

                        // Trend sparklines
                        trendsSection

                        // Episode tally
                        if !viewModel.episodeTally.isEmpty {
                            episodeSection
                        }

                        // Insights
                        if !viewModel.activeInsights.isEmpty {
                            insightsSection
                        }

                        // Quick actions
                        actionButtons
                    } else {
                        noCompanionPrompt
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .withEmberBackdrop()
            .navigationTitle("Pulse")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.refresh()
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    animateCards = true
                }
            }
            .navigationDestination(for: PathwayCoordinator.Waypoint.self) { waypoint in
                waypointDestination(waypoint)
            }
        }
        // Badge celebration overlay
        .overlay { badgeCelebration }
        // Toast
        .overlay(alignment: .bottom) { toastOverlay }
    }

    // MARK: - Companion Strip

    private var companionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.allCompanions) { companion in
                    companionChip(companion)
                }

                // Add button
                Button {
                    coordinator.openPortal(.addCompanion)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text("Add")
                            .font(AuraFont.captionWhisper())
                    }
                    .foregroundColor(AuraPalette.lifeGold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AuraPalette.goldMist)
                    .cornerRadius(20)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func companionChip(_ companion: CompanionProfile) -> some View {
        let isActive = companion.id == viewModel.activeCompanion?.id

        return Button {
            viewModel.selectCompanion(companion)
            coordinator.focusCompanion(companion.id)
        } label: {
            HStack(spacing: 6) {
                Text(companion.avatarEmoji)
                    .font(.system(size: 18))
                Text(companion.name)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(isActive ? AuraPalette.restingNight : AuraPalette.boneWhite)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isActive ? AuraPalette.lifeGold : AuraPalette.healingCharcoal)
            .cornerRadius(20)
        }
    }

    // MARK: - Vitality Banner (XP + Level + Streak)

    private var vitalityBanner: some View {
        VStack(spacing: 12) {
            HStack {
                // Level badge
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lv. \(viewModel.vitality.currentLevel)")
                        .font(AuraFont.sectionHeadline())
                        .foregroundColor(AuraPalette.lifeGold)
                    Text(viewModel.vitality.levelTitle)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                }

                Spacer()

                // Streak
                if viewModel.vitality.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AuraPalette.streakFlame)
                            .font(.system(size: 18))
                        Text("\(viewModel.vitality.currentStreak)")
                            .font(AuraFont.streakDigit())
                            .foregroundColor(AuraPalette.streakFlame)
                    }
                }

                // XP count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.vitality.totalXP) XP")
                        .font(AuraFont.xpCounter())
                        .foregroundColor(AuraPalette.experienceGlow)
                    Text("Next: \(viewModel.vitality.xpForNextLevel)")
                        .font(AuraFont.badgeStamp())
                        .foregroundColor(AuraPalette.whisperAsh)
                }
            }

            // XP progress bar
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
            .frame(height: 8)
        }
        .padding(16)
        .background(AuraPalette.shelterSmoke.opacity(0.7))
        .cornerRadius(16)
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
    }

    // MARK: - Quick Scales

    private var scalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Today's Check-in", icon: "hand.tap.fill")

            VStack(spacing: 10) {
                ForEach(viewModel.enabledAxisInfos) { axis in
                    scaleRow(axis)
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private func scaleRow(_ axis: CategoryResolver.AxisInfo) -> some View {
        let currentValue = viewModel.todayLog?.scaleValue(forAxisId: axis.id)
        let hintForVal: (Int) -> String? = { val in
            guard val >= 1, val <= axis.levelHints.count else { return nil }
            return axis.levelHints[val - 1]
        }

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: axis.icon)
                    .foregroundColor(AuraPalette.lifeGold)
                    .font(.system(size: 14))
                Text(axis.name)
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)

                Spacer()

                if let val = currentValue, let hint = hintForVal(val) {
                    Text(hint)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                        .transition(.opacity)
                }
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.tapScale(axisId: axis.id, value: level, axisName: axis.name)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    currentValue == level
                                    ? AuraPalette.lifeGold
                                    : (currentValue != nil && level <= currentValue!)
                                    ? AuraPalette.lifeGold.opacity(0.4)
                                    : AuraPalette.healingCharcoal
                                )

                            Text("\(level)")
                                .font(AuraFont.scaleValue())
                                .foregroundColor(
                                    currentValue == level
                                    ? AuraPalette.restingNight
                                    : AuraPalette.mistBreath
                                )
                        }
                        .frame(height: 44)
                    }
                }
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Trends Section

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "7-Day Trends", icon: "chart.xyaxis.line")

            VStack(spacing: 10) {
                ForEach(viewModel.enabledAxisInfos) { axis in
                    if let points = viewModel.trendSnapshots[axis.id], !points.isEmpty {
                        trendCard(axis: axis, points: points)
                    }
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private func trendCard(axis: CategoryResolver.AxisInfo, points: [TrendPoint]) -> some View {
        Button {
            if let builtIn = WellnessAxis(rawValue: axis.id) {
                coordinator.navigate(to: .trendDetail(builtIn))
            } else {
                coordinator.navigate(to: .trendDetailCustom(axis.id))
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: axis.icon)
                    .foregroundColor(AuraPalette.lifeGold)
                    .font(.system(size: 16))
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(axis.name)
                        .font(AuraFont.cardTitle())
                        .foregroundColor(AuraPalette.boneWhite)

                    Text(trendSummary(points))
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                }

                Spacer()

                // Mini sparkline
                sparkline(points: points)
                    .frame(width: 80, height: 30)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
    }

    private func sparkline(points: [TrendPoint]) -> some View {
        GeometryReader { geo in
            let values = points.map { CGFloat($0.value) }
            let maxVal: CGFloat = 5
            let minVal: CGFloat = 1
            let range = maxVal - minVal
            let stepX = geo.size.width / CGFloat(max(values.count - 1, 1))

            Path { path in
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = geo.size.height - ((value - minVal) / range) * geo.size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(AuraPalette.lifeGold, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }

    private func trendSummary(_ points: [TrendPoint]) -> String {
        guard points.count >= 2 else { return "\(points.count) day logged" }
        let avg = Double(points.map(\.value).reduce(0, +)) / Double(points.count)
        return String(format: "Avg %.1f · %d days", avg, points.count)
    }

    // MARK: - Episode Section

    private var episodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Episodes This Week", icon: "exclamationmark.bubble.fill")

            FlowLayout(spacing: 8) {
                ForEach(Array(viewModel.episodeTally.keys), id: \.self) { kind in
                    if let count = viewModel.episodeTally[kind] {
                        episodeChip(kind: kind, count: count)
                    }
                }
            }
            .padding(14)
            .background(AuraPalette.shelterSmoke.opacity(0.5))
            .cornerRadius(14)
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private func episodeChip(kind: SymptomKind, count: Int) -> some View {
        HStack(spacing: 6) {
            Image(systemName: kind.icon)
                .font(.system(size: 12))
                .foregroundColor(AuraPalette.emberWarn)
            Text("\(kind.displayName)")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.boneWhite)
            Text("×\(count)")
                .font(AuraFont.badgeStamp())
                .foregroundColor(AuraPalette.lifeGold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AuraPalette.healingCharcoal)
        .cornerRadius(10)
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Observations", icon: "eye.fill")

            VStack(spacing: 8) {
                ForEach(viewModel.activeInsights) { insight in
                    insightCard(insight)
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 15)
    }

    private func insightCard(_ insight: ObservationInsight) -> some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.system(size: 18))
                .foregroundColor(insightColor(insight.kind))
                .frame(width: 28)

            Text(insight.message)
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.boneWhite)
                .lineLimit(2)

            Spacer()

            Button {
                withAnimation { viewModel.dismissInsight(insight) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AuraPalette.shelterSmoke.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(insightColor(insight.kind).opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    private func insightColor(_ kind: ObservationInsight.InsightTone) -> Color {
        switch kind {
        case .positive:  return AuraPalette.sproutGreen
        case .attention: return AuraPalette.emberWarn
        case .neutral:   return AuraPalette.calmSky
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                coordinator.quickAddEpisode()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log Episode")
                }
                .font(AuraFont.cardTitle())
                .foregroundColor(AuraPalette.restingNight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AuraPalette.lifeGold)
                .cornerRadius(14)
            }

            HStack(spacing: 10) {
                Button {
                    coordinator.quickOpenBadges()
                } label: {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("Badges")
                    }
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.lifeGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AuraPalette.goldMist)
                    .cornerRadius(12)
                }

                Button {
                    coordinator.quickOpenStats()
                } label: {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats")
                    }
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.lifeGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AuraPalette.goldMist)
                    .cornerRadius(12)
                }
            }
        }
        .opacity(animateCards ? 1 : 0)
    }

    // MARK: - Empty States

    private var emptyPrompt: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)

            Text("🌱")
                .font(.system(size: 56))

            Text("Start Your First Check-in")
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)

            Text("Rate your companion's wellness scales\nbelow to begin tracking patterns.")
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.mistBreath)
                .multilineTextAlignment(.center)

            scalesSection

            Spacer()
        }
    }

    private var noCompanionPrompt: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)

            Text("🐾")
                .font(.system(size: 56))

            Text("No Companion Yet")
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)

            Text("Add your first companion\nto start observing their wellness.")
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.mistBreath)
                .multilineTextAlignment(.center)

            Button {
                coordinator.openPortal(.addCompanion)
            } label: {
                Text("Add Companion")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.restingNight)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AuraPalette.lifeGold)
                    .cornerRadius(14)
            }

            Spacer()
        }
    }

    // MARK: - Badge Celebration Overlay

    @ViewBuilder
    private var badgeCelebration: some View {
        if let badge = viewModel.newBadgeEarned {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.acknowledgeBadge() }

                VStack(spacing: 16) {
                    Text("Badge Unlocked!")
                        .font(AuraFont.sectionHeadline())
                        .foregroundColor(AuraPalette.lifeGold)

                    Text(badge.icon)
                        .font(.system(size: 64))

                    Text(badge.displayName)
                        .font(AuraFont.heroTitle())
                        .foregroundColor(AuraPalette.boneWhite)

                    Text(badge.requirement)
                        .font(AuraFont.bodyPulse())
                        .foregroundColor(AuraPalette.mistBreath)
                        .multilineTextAlignment(.center)

                    Text("+\(XPReward.badgeUnlock) XP")
                        .font(AuraFont.xpCounter())
                        .foregroundColor(AuraPalette.experienceGlow)
                        .padding(.top, 4)

                    Button {
                        viewModel.acknowledgeBadge()
                    } label: {
                        Text("Awesome!")
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.restingNight)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(AuraPalette.lifeGold)
                            .cornerRadius(14)
                    }
                    .padding(.top, 8)
                }
                .padding(32)
                .background(AuraPalette.shelterSmoke)
                .cornerRadius(24)
                .shadow(color: AuraPalette.lifeGold.opacity(0.3), radius: 20)
                .padding(.horizontal, 40)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: viewModel.newBadgeEarned != nil)
        }
    }

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if let text = viewModel.toastText {
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

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AuraPalette.lifeGold)
                .font(.system(size: 14))
            Text(title)
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)
            Spacer()
        }
    }

    @ViewBuilder
    private func waypointDestination(_ waypoint: PathwayCoordinator.Waypoint) -> some View {
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
}

// MARK: - FlowLayout (simple wrapping layout)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
