import SwiftUI

// MARK: - CareView
// Care tab: calendar with reminders, vet visits, pills, vaccines, etc.

struct CareView: View {

    @ObservedObject var viewModel: CareViewModel
    @ObservedObject var coordinator: PathwayCoordinator

    @State private var animateIn: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.carePath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    companionStrip

                    monthHeader

                    calendarGrid

                    selectedDayDetail
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .withEmberBackdrop()
            .navigationTitle("Care")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            coordinator.openPortal(.addReminder(companionId: viewModel.activeCompanion?.id))
                        } label: {
                            Label("Add Reminder", systemImage: "bell.badge.fill")
                        }
                        if let id = viewModel.activeCompanion?.id {
                            Button {
                                coordinator.openPortal(.addVetVisit(companionId: id))
                            } label: {
                                Label("Log Vet Visit", systemImage: "stethoscope")
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AuraPalette.lifeGold)
                    }
                }
            }
            .onAppear {
                viewModel.refresh()
                withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                    animateIn = true
                }
            }
        }
        .overlay(alignment: .bottom) { toastOverlay }
    }

    // MARK: - Companion Strip

    private var companionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    viewModel.selectCompanion(nil)
                } label: {
                    HStack(spacing: 6) {
                        Text("All")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(
                                viewModel.activeCompanion == nil
                                ? AuraPalette.restingNight
                                : AuraPalette.mistBreath
                            )
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.activeCompanion == nil
                        ? AuraPalette.lifeGold
                        : AuraPalette.healingCharcoal
                    )
                    .cornerRadius(20)
                }

                ForEach(viewModel.allCompanions) { companion in
                    let isActive = companion.id == viewModel.activeCompanion?.id
                    Button {
                        viewModel.selectCompanion(companion)
                    } label: {
                        HStack(spacing: 6) {
                            Text(companion.avatarEmoji)
                                .font(.system(size: 16))
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

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                viewModel.changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AuraPalette.lifeGold)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearFormatted(viewModel.displayedMonth))
                .font(AuraFont.sectionHeadline())
                .foregroundColor(AuraPalette.boneWhite)

            Spacer()

            Button {
                viewModel.changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AuraPalette.lifeGold)
                    .frame(width: 44, height: 44)
            }
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(1))
                        .font(AuraFont.badgeStamp())
                        .foregroundColor(AuraPalette.whisperAsh)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(viewModel.calendarDays) { day in
                    calendarDayCell(day)
                }
            }
        }
        .padding(14)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }

    private func calendarDayCell(_ day: CareCalendarDay) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectDay(day.date)
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(day.dayNumber)")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(
                        day.isSelected ? AuraPalette.restingNight : AuraPalette.boneWhite
                    )

                if day.hasEvent {
                    Circle()
                        .fill(AuraPalette.lifeGold)
                        .frame(width: 5, height: 5)
                } else {
                    Spacer().frame(height: 5)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        day.isSelected
                        ? AuraPalette.lifeGold
                        : day.isToday
                        ? AuraPalette.goldMist
                        : AuraPalette.healingCharcoal.opacity(0.6)
                    )
            )
        }
    }

    // MARK: - Selected Day Detail

    private var selectedDayDetail: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            }

            if viewModel.remindersForSelectedDay.isEmpty && viewModel.vetVisitsForSelectedDay.isEmpty {
                emptyDayPrompt
            } else {
                if !viewModel.remindersForSelectedDay.isEmpty {
                    remindersSection
                }
                if !viewModel.vetVisitsForSelectedDay.isEmpty {
                    vetVisitsSection
                }
            }
        }
        .padding(16)
        .background(AuraPalette.shelterSmoke.opacity(0.5))
        .cornerRadius(16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }

    private var emptyDayPrompt: some View {
        VStack(spacing: 12) {
            Text("📅")
                .font(.system(size: 40))
            Text("Nothing scheduled")
                .font(AuraFont.cardTitle())
                .foregroundColor(AuraPalette.mistBreath)
            Text("Tap + to add a reminder or log a vet visit")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.whisperAsh)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AuraPalette.lifeGold)
                Text("Reminders")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)
            }

            ForEach(viewModel.remindersForSelectedDay) { reminder in
                reminderRow(reminder)
            }
        }
    }

    private func reminderRow(_ reminder: CareReminder) -> some View {
        let kindInfo = CategoryResolver.reminderKindInfo(
            kindId: reminder.kindId,
            customKinds: GroveStorage.shared.settings.customReminderKinds
        )
        return HStack(spacing: 12) {
            Image(systemName: kindInfo.icon)
                .font(.system(size: 18))
                .foregroundColor(AuraPalette.lifeGold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)
                Text(kindInfo.name)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.mistBreath)
                if !reminder.note.isEmpty {
                    Text(reminder.note)
                        .font(.system(size: 11))
                        .foregroundColor(AuraPalette.whisperAsh)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button {
                viewModel.deleteReminder(reminder)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(12)
        .background(AuraPalette.healingCharcoal)
        .cornerRadius(12)
    }

    private var vetVisitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 14))
                    .foregroundColor(AuraPalette.lifeGold)
                Text("Vet Visits")
                    .font(AuraFont.cardTitle())
                    .foregroundColor(AuraPalette.boneWhite)
            }

            ForEach(viewModel.vetVisitsForSelectedDay) { visit in
                vetVisitRow(visit)
            }
        }
    }

    private func vetVisitRow(_ visit: VetVisit) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .font(.system(size: 18))
                .foregroundColor(AuraPalette.calmSky)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                if !visit.vetName.isEmpty {
                    Text(visit.vetName)
                        .font(AuraFont.cardTitle())
                        .foregroundColor(AuraPalette.boneWhite)
                }
                if !visit.reason.isEmpty {
                    Text(visit.reason)
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                }
                if !visit.notes.isEmpty {
                    Text(visit.notes)
                        .font(.system(size: 11))
                        .foregroundColor(AuraPalette.whisperAsh)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button {
                viewModel.deleteVetVisit(visit)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AuraPalette.whisperAsh)
            }
        }
        .padding(12)
        .background(AuraPalette.healingCharcoal)
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func monthYearFormatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: date)
    }

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
}
