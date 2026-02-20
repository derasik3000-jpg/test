import SwiftUI

// MARK: - ChronicleView
// Second tab: Daily Logs (calendar + scales) and Episodes (filtered list)

struct ChronicleView: View {

    @ObservedObject var viewModel: ChronicleViewModel
    @ObservedObject var coordinator: PathwayCoordinator

    @FocusState private var isNoteFieldFocused: Bool
    @State private var animateIn: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.chroniclePath) {
            VStack(spacing: 0) {
                // Companion selector
                companionStrip
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                // Mode toggle
                modeToggle
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch viewModel.activeMode {
                        case .logs:
                            logsContent
                        case .events:
                            eventsContent
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .padding(.top, 12)
                }
            }
            .withEmberBackdrop()
            .navigationTitle("Chronicle")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.refresh()
                withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                    animateIn = true
                }
            }
            .navigationDestination(for: PathwayCoordinator.Waypoint.self) { waypoint in
                waypointDestination(waypoint)
            }
        }
        .overlay(alignment: .bottom) { toastOverlay }
    }

    // MARK: - Companion Strip

    private var companionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.allCompanions) { companion in
                    let isActive = companion.id == viewModel.activeCompanion?.id
                    Button {
                        viewModel.selectCompanion(companion)
                        coordinator.focusCompanion(companion.id)
                    } label: {
                        HStack(spacing: 6) {
                            Text(companion.avatarEmoji)
                                .font(.system(size: 16))
                            Text(companion.name)
                                .font(AuraFont.captionWhisper())
                                .foregroundColor(isActive ? AuraPalette.restingNight : AuraPalette.boneWhite)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(isActive ? AuraPalette.lifeGold : AuraPalette.healingCharcoal)
                        .cornerRadius(18)
                    }
                }
            }
        }
    }

    // MARK: - Mode Toggle

    private var modeToggle: some View {
        HStack(spacing: 0) {
            ForEach(ChronicleViewModel.LedgerMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.switchMode(mode)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 13))
                        Text(mode.displayName)
                            .font(AuraFont.captionWhisper())
                    }
                    .foregroundColor(
                        viewModel.activeMode == mode
                        ? AuraPalette.restingNight
                        : AuraPalette.mistBreath
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.activeMode == mode
                        ? AuraPalette.lifeGold
                        : AuraPalette.healingCharcoal
                    )
                }
            }
        }
        .cornerRadius(12)
    }

    // MARK: - Logs Content

    private var logsContent: some View {
        VStack(spacing: 16) {
            // Calendar strip
            calendarStrip

            // Selected date header
            dateHeader

            // Scales editor
            scalesEditor

            // Day note
            dayNoteEditor

            // Action row
            logActions
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }

    // MARK: - Calendar Strip

    private var calendarStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.calendarDays) { day in
                        calendarDayView(day)
                            .id(day.dateKey)
                    }
                }
                .padding(.vertical, 4)
            }
            .onAppear {
                proxy.scrollTo(viewModel.selectedDateKey, anchor: .center)
            }
            .onChange(of: viewModel.selectedDateKey) { newKey in
                withAnimation { proxy.scrollTo(newKey, anchor: .center) }
            }
        }
    }

    private func calendarDayView(_ day: CalendarDayCell) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectDay(day.dateKey)
            }
        } label: {
            VStack(spacing: 4) {
                Text(day.weekdayLabel)
                    .font(AuraFont.badgeStamp())
                    .foregroundColor(
                        day.isSelected ? AuraPalette.restingNight : AuraPalette.whisperAsh
                    )

                Text("\(day.dayNumber)")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(
                        day.isSelected ? AuraPalette.restingNight : AuraPalette.boneWhite
                    )

                // Indicators
                HStack(spacing: 3) {
                    if day.hasLog {
                        Circle()
                            .fill(AuraPalette.sproutGreen)
                            .frame(width: 5, height: 5)
                    }
                    if day.episodeCount > 0 {
                        Circle()
                            .fill(AuraPalette.emberWarn)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(width: 46, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        day.isSelected
                        ? AuraPalette.lifeGold
                        : day.isToday
                        ? AuraPalette.goldMist
                        : AuraPalette.healingCharcoal
                    )
            )
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.selectedDateFormatted)
                    .font(AuraFont.sectionHeadline())
                    .foregroundColor(AuraPalette.boneWhite)

                if viewModel.isSelectedToday {
                    Text("Today")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.lifeGold)
                }
            }

            Spacer()

            // Filled scales count
            if let log = viewModel.selectedLog {
                let filled = log.scales.values.filter { $0 > 0 }.count
                let total = viewModel.enabledAxisInfos.count
                Text("\(filled)/\(total)")
                    .font(AuraFont.xpCounter())
                    .foregroundColor(
                        filled == total ? AuraPalette.sproutGreen : AuraPalette.mistBreath
                    )
            }
        }
    }

    // MARK: - Scales Editor

    private var scalesEditor: some View {
            VStack(spacing: 10) {
                ForEach(viewModel.enabledAxisInfos) { axis in
                    chronicleScaleRow(axis)
                }
            }
    }

    private func chronicleScaleRow(_ axis: CategoryResolver.AxisInfo) -> some View {
        let currentValue = viewModel.selectedLog?.scaleValue(forAxisId: axis.id)
        let hintForVal: (Int) -> String? = { val in
            guard val >= 1, val <= axis.levelHints.count else { return nil }
            return axis.levelHints[val - 1]
        }

        return VStack(alignment: .leading, spacing: 8) {
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
                }
            }

            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            viewModel.tapScale(axisId: axis.id, value: level)
                        }
                    } label: {
                        Text("\(level)")
                            .font(AuraFont.scaleValue())
                            .foregroundColor(
                                currentValue == level
                                ? AuraPalette.restingNight
                                : currentValue != nil && level <= currentValue!
                                ? AuraPalette.lifeGold
                                : AuraPalette.mistBreath
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        currentValue == level
                                        ? AuraPalette.lifeGold
                                        : currentValue != nil && level <= currentValue!
                                        ? AuraPalette.lifeGold.opacity(0.25)
                                        : AuraPalette.healingCharcoal
                                    )
                            )
                    }
                }
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Day Note Editor

    private var dayNoteEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(AuraPalette.lifeGold)
                    .font(.system(size: 14))
                Text("Day Note")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)

                Spacer()

                if viewModel.hasUnsavedChanges {
                    Button {
                        viewModel.saveDayNote()
                        isNoteFieldFocused = false
                    } label: {
                        Text("Save")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.restingNight)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(AuraPalette.lifeGold)
                            .cornerRadius(8)
                    }
                }
            }

            TextField("", text: Binding(
                get: { viewModel.dayNoteText },
                set: { viewModel.updateDayNote($0) }
            ), axis: .vertical)
            .placeholder(when: viewModel.dayNoteText.isEmpty) {
                Text("e.g. Changed food brand, went to the park…")
                    .foregroundColor(AuraPalette.whisperAsh)
            }
            .font(AuraFont.bodyPulse())
            .foregroundColor(AuraPalette.boneWhite)
            .lineLimit(1...4)
            .focused($isNoteFieldFocused)
            .padding(12)
            .background(AuraPalette.healingCharcoal)
            .cornerRadius(10)
            .onSubmit {
                viewModel.saveDayNote()
                isNoteFieldFocused = false
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Log Actions

    private var logActions: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.copyPreviousDay()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13))
                    Text("Copy Previous")
                        .font(AuraFont.captionWhisper())
                }
                .foregroundColor(AuraPalette.lifeGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AuraPalette.goldMist)
                .cornerRadius(12)
            }

            Button {
                coordinator.quickAddEpisode()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13))
                    Text("Add Episode")
                        .font(AuraFont.captionWhisper())
                }
                .foregroundColor(AuraPalette.restingNight)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AuraPalette.lifeGold)
                .cornerRadius(12)
            }

            Button {
                viewModel.clearDay()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(AuraPalette.emberWarn)
                    .frame(width: 44, height: 44)
                    .background(AuraPalette.healingCharcoal)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Events Content

    private var eventsContent: some View {
        VStack(spacing: 16) {
            // Range selector
            rangeSelector

            // Filter chips
            filterChips

            // Stats mini-bar
            if !viewModel.filteredEpisodes.isEmpty {
                episodeStatsBanner
            }

            // Episodes list
            if viewModel.filteredEpisodes.isEmpty {
                emptyEpisodesPrompt
            } else {
                episodesList
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }

    // MARK: - Range Selector

    private var rangeSelector: some View {
        HStack(spacing: 8) {
            ForEach(ChronicleRange.allCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.setRangeDays(range.rawValue)
                    }
                } label: {
                    Text(range.displayName)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(
                            viewModel.rangeDays == range.rawValue
                            ? AuraPalette.restingNight
                            : AuraPalette.mistBreath
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.rangeDays == range.rawValue
                            ? AuraPalette.lifeGold
                            : AuraPalette.healingCharcoal
                        )
                        .cornerRadius(10)
                }
            }

            Spacer()

            Button {
                coordinator.quickAddEpisode()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AuraPalette.lifeGold)
            }
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All chip
                filterChip(title: "All", icon: "tray.full.fill", isActive: viewModel.episodeFilter == nil) {
                    viewModel.setEpisodeFilter(nil)
                }

                ForEach(SymptomKind.allCases.filter { $0 != .custom }) { kind in
                    filterChip(title: kind.displayName, icon: kind.icon, isActive: viewModel.episodeFilter == kind) {
                        viewModel.setEpisodeFilter(kind)
                    }
                }
            }
        }
    }

    private func filterChip(title: String, icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(AuraFont.badgeStamp())
            }
            .foregroundColor(isActive ? AuraPalette.restingNight : AuraPalette.mistBreath)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? AuraPalette.lifeGold : AuraPalette.healingCharcoal)
            .cornerRadius(10)
        }
    }

    // MARK: - Episode Stats Banner

    private var episodeStatsBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.totalEpisodesInRange) episodes")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)
                Text("in last \(viewModel.rangeDays) days")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)
            }

            Spacer()

            // Top kinds
            HStack(spacing: 8) {
                ForEach(viewModel.episodeKindCounts.prefix(3), id: \.kind) { item in
                    HStack(spacing: 4) {
                        Image(systemName: item.kind.icon)
                            .font(.system(size: 11))
                            .foregroundColor(AuraPalette.emberWarn)
                        Text("×\(item.count)")
                            .font(AuraFont.badgeStamp())
                            .foregroundColor(AuraPalette.mistBreath)
                    }
                }
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
    }

    // MARK: - Episodes List

    private var episodesList: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.filteredEpisodes) { episode in
                episodeCard(episode)
            }
        }
    }

    private func episodeCard(_ episode: SymptomEpisode) -> some View {
        HStack(spacing: 12) {
            // Severity indicator
            Circle()
                .fill(severityColor(episode.severity))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: episode.kind.icon)
                        .font(.system(size: 13))
                        .foregroundColor(AuraPalette.emberWarn)
                    Text(episode.displayTitle)
                        .font(AuraFont.cardTitle())
                        .foregroundColor(AuraPalette.boneWhite)
                }

                HStack(spacing: 8) {
                    Text(episode.severity.displayName)
                        .font(AuraFont.badgeStamp())
                        .foregroundColor(severityColor(episode.severity))

                    if episode.occurrenceCount > 1 {
                        Text("×\(episode.occurrenceCount)")
                            .font(AuraFont.badgeStamp())
                            .foregroundColor(AuraPalette.mistBreath)
                    }

                    if let mins = episode.durationMinutes {
                        Text("\(mins) min")
                            .font(AuraFont.badgeStamp())
                            .foregroundColor(AuraPalette.mistBreath)
                    }

                    Spacer()

                    Text(episodeTimeFormatted(episode.occurredAt))
                        .font(AuraFont.badgeStamp())
                        .foregroundColor(AuraPalette.whisperAsh)
                }

                if !episode.note.isEmpty {
                    Text(episode.note)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)

            // Delete
            Button {
                withAnimation(.spring(response: 0.3)) {
                    viewModel.deleteEpisode(episode)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(14)
        .transition(.asymmetric(
            insertion: .slide.combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }

    // MARK: - Empty Episodes

    private var emptyEpisodesPrompt: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 32)

            Text("📋")
                .font(.system(size: 48))

            Text("No Episodes Recorded")
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)

            Text("Tap + to log a symptom episode\nwhen you observe something.")
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.mistBreath)
                .multilineTextAlignment(.center)

            Button {
                coordinator.quickAddEpisode()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log First Episode")
                }
                .font(AuraFont.cardTitle())
                .foregroundColor(AuraPalette.restingNight)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AuraPalette.lifeGold)
                .cornerRadius(14)
            }

            Spacer()
        }
    }

    // MARK: - Helpers

    private func severityColor(_ severity: SeverityLevel) -> Color {
        switch severity {
        case .mild:     return AuraPalette.sproutGreen
        case .moderate: return AuraPalette.lifeGold
        case .severe:   return AuraPalette.emberWarn
        }
    }

    private func episodeTimeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
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

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if viewModel.showUndoEpisodeToast, let text = viewModel.toastText {
            HStack(spacing: 12) {
                Text(text)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.boneWhite)
                Button("Undo") {
                    viewModel.undoEpisodeDelete()
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
            .animation(.spring(response: 0.4), value: viewModel.showUndoEpisodeToast)
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
