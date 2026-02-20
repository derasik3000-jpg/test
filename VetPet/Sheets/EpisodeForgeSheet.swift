import SwiftUI

struct EpisodeForgeSheet: View {

    let companionId: UUID
    let onDismiss: () -> Void

    @StateObject private var forge = EpisodeForgeViewModel()
    @FocusState private var isNoteFocused: Bool
    @State private var animateIn: Bool = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Symptom type grid
                        symptomTypeSection

                        // Severity picker
                        severitySection

                        // Occurrence count
                        occurrenceSection

                        // Duration
                        durationSection

                        // Time picker
                        timeSection

                        // Note
                        noteSection
                            .id("noteField")

                        // Spacer for keyboard
                        Spacer().frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
                .onChange(of: isNoteFocused) { focused in
                    if focused {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation { scrollProxy.scrollTo("noteField", anchor: .bottom) }
                        }
                    }
                }
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Log Episode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(AuraPalette.mistBreath)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndClose() }
                        .font(AuraFont.cardTitle())
                        .foregroundColor(
                            forge.canSave ? AuraPalette.lifeGold : AuraPalette.whisperAsh
                        )
                        .disabled(!forge.canSave)
                }
            }
            .onAppear {
                forge.prepare(companionId: companionId)
                withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                    animateIn = true
                }
            }
        }
    }

    // MARK: - Symptom Type

    private var symptomTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("What happened?", icon: "stethoscope")

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(SymptomKind.allCases) { kind in
                    symptomChip(kind)
                }
            }

            // Custom title field
            if forge.selectedKind == .custom {
                TextField("", text: $forge.customTitle)
                    .placeholder(when: forge.customTitle.isEmpty) {
                        Text("Describe the symptom…")
                            .foregroundColor(AuraPalette.whisperAsh)
                    }
                    .font(AuraFont.bodyPulse())
                    .foregroundColor(AuraPalette.boneWhite)
                    .padding(12)
                    .background(AuraPalette.healingCharcoal)
                    .cornerRadius(10)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }

    private func symptomChip(_ kind: SymptomKind) -> some View {
        let isSelected = forge.selectedKind == kind

        return Button {
            withAnimation(.spring(response: 0.25)) {
                forge.selectedKind = kind
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: kind.icon)
                    .font(.system(size: 18))
                    .foregroundColor(
                        isSelected ? AuraPalette.restingNight : AuraPalette.emberWarn
                    )

                Text(kind.displayName)
                    .font(AuraFont.badgeStamp())
                    .foregroundColor(
                        isSelected ? AuraPalette.restingNight : AuraPalette.mistBreath
                    )
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? AuraPalette.lifeGold : AuraPalette.healingCharcoal
            )
            .cornerRadius(12)
        }
    }

    // MARK: - Severity

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("Severity", icon: "gauge.medium")

            HStack(spacing: 10) {
                ForEach(SeverityLevel.allCases) { level in
                    severityButton(level)
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }

    private func severityButton(_ level: SeverityLevel) -> some View {
        let isSelected = forge.severity == level

        return Button {
            withAnimation(.spring(response: 0.25)) {
                forge.severity = level
            }
        } label: {
            VStack(spacing: 6) {
                Circle()
                    .fill(severityColor(level))
                    .frame(width: isSelected ? 20 : 14, height: isSelected ? 20 : 14)
                    .animation(.spring(response: 0.3), value: isSelected)

                Text(level.displayName)
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(
                        isSelected ? AuraPalette.boneWhite : AuraPalette.mistBreath
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AuraPalette.healingCharcoal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? severityColor(level) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }

    // MARK: - Occurrence Count

    private var occurrenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("How many times?", icon: "number")

            HStack(spacing: 8) {
                ForEach([1, 2, 3, 5, 10], id: \.self) { count in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            forge.occurrenceCount = count
                        }
                    } label: {
                        Text("\(count)")
                            .font(AuraFont.scaleValue())
                            .foregroundColor(
                                forge.occurrenceCount == count
                                ? AuraPalette.restingNight
                                : AuraPalette.mistBreath
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                forge.occurrenceCount == count
                                ? AuraPalette.lifeGold
                                : AuraPalette.healingCharcoal
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("Duration (optional)", icon: "clock")

            HStack(spacing: 8) {
                ForEach([
                    (label: "Brief", value: 1),
                    (label: "5 min", value: 5),
                    (label: "15 min", value: 15),
                    (label: "30 min", value: 30),
                    (label: "1 hr+", value: 60)
                ], id: \.value) { option in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            forge.durationMinutes = forge.durationMinutes == option.value ? nil : option.value
                        }
                    } label: {
                        Text(option.label)
                            .font(AuraFont.badgeStamp())
                            .foregroundColor(
                                forge.durationMinutes == option.value
                                ? AuraPalette.restingNight
                                : AuraPalette.mistBreath
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                forge.durationMinutes == option.value
                                ? AuraPalette.lifeGold
                                : AuraPalette.healingCharcoal
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
    }

    // MARK: - Time

    private var timeSection: some View {
        VStack(spacing: 10) {
            fieldLabel("When?", icon: "clock.arrow.circlepath")
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                // Quick picks
                Button {
                    withAnimation { forge.occurredAt = Date() }
                } label: {
                    Text("Right now")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.lifeGold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AuraPalette.goldMist)
                        .cornerRadius(10)
                }

                Button {
                    withAnimation {
                        forge.occurredAt = Date().addingTimeInterval(-1800) // 30 min ago
                    }
                } label: {
                    Text("30 min ago")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AuraPalette.healingCharcoal)
                        .cornerRadius(10)
                }

                Button {
                    withAnimation {
                        forge.occurredAt = Date().addingTimeInterval(-3600) // 1 hr ago
                    }
                } label: {
                    Text("1 hr ago")
                        .font(AuraFont.captionWhisper())
                        .foregroundColor(AuraPalette.mistBreath)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AuraPalette.healingCharcoal)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity)

            DatePicker(
                "",
                selection: $forge.occurredAt,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .colorScheme(.dark)
            .tint(AuraPalette.lifeGold)
            .frame(maxWidth: .infinity)
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("Note (optional)", icon: "text.bubble")

            TextField("", text: $forge.note, axis: .vertical)
                .placeholder(when: forge.note.isEmpty) {
                    Text("Any extra details — food eaten, behavior, location…")
                        .foregroundColor(AuraPalette.whisperAsh)
                }
                .font(AuraFont.bodyPulse())
                .foregroundColor(AuraPalette.boneWhite)
                .lineLimit(2...6)
                .focused($isNoteFocused)
                .padding(14)
                .background(AuraPalette.healingCharcoal)
                .cornerRadius(12)
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(AuraPalette.lifeGold)
            Text(text)
                .font(AuraFont.cardTitle())
                .foregroundColor(AuraPalette.boneWhite)
        }
    }

    private func severityColor(_ level: SeverityLevel) -> Color {
        switch level {
        case .mild:     return AuraPalette.sproutGreen
        case .moderate: return AuraPalette.lifeGold
        case .severe:   return AuraPalette.emberWarn
        }
    }

    private func saveAndClose() {
        forge.save()
        onDismiss()
    }
}

