import SwiftUI

struct CareReminderSheet: View {

    let companionId: UUID?
    let onDismiss: () -> Void

    @State private var kindId: String = CareReminderKind.pills.rawValue
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var notificationTime: Date = Self.defaultNotificationTime
    @State private var note: String = ""

    private static var defaultNotificationTime: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 9
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }
    @State private var isRecurring: Bool = false
    @State private var recurringDays: Int = 7

    var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    kindPicker

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $title)
                            .placeholder(when: title.isEmpty) {
                                Text(kindId == CareReminderKind.birthday.rawValue ? "e.g. Max's birthday" : "e.g. Morning pills")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    datePicker

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notification time")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(AuraPalette.lifeGold)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Repeat", isOn: $isRecurring)
                            .tint(AuraPalette.lifeGold)
                        if isRecurring {
                            HStack(spacing: 8) {
                                ForEach([1, 7, 14, 30, 365], id: \.self) { days in
                                    Button {
                                        recurringDays = days
                                    } label: {
                                        Text(days == 1 ? "Daily" : days == 365 ? "Yearly" : "Every \(days) days")
                                            .font(AuraFont.badgeStamp())
                                            .foregroundColor(
                                                recurringDays == days
                                                ? AuraPalette.restingNight
                                                : AuraPalette.mistBreath
                                            )
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                recurringDays == days
                                                ? AuraPalette.lifeGold
                                                : AuraPalette.healingCharcoal
                                            )
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Note (optional)")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $note, axis: .vertical)
                            .placeholder(when: note.isEmpty) {
                                Text("Extra details…")
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
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(AuraPalette.mistBreath)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .font(AuraFont.cardTitle())
                        .foregroundColor(canSave ? AuraPalette.lifeGold : AuraPalette.whisperAsh)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var kindPicker: some View {
        let kinds = CategoryResolver.allReminderKinds(customKinds: GroveStorage.shared.settings.customReminderKinds)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Type")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(kinds, id: \.id) { k in
                    Button {
                        withAnimation(.spring(response: 0.25)) { kindId = k.id }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: k.icon)
                                .font(.system(size: 20))
                                .foregroundColor(kindId == k.id ? AuraPalette.restingNight : AuraPalette.lifeGold)
                            Text(k.name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(kindId == k.id ? AuraPalette.restingNight : AuraPalette.mistBreath)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(kindId == k.id ? AuraPalette.lifeGold : AuraPalette.healingCharcoal)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Date")
                .font(AuraFont.captionWhisper())
                .foregroundColor(AuraPalette.mistBreath)
            DatePicker("", selection: $dueDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(AuraPalette.lifeGold)
        }
    }

    private func save() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeOfDay = formatter.string(from: notificationTime)

        let reminder = CareReminder(
            companionId: companionId,
            kindId: kindId,
            title: title.trimmingCharacters(in: .whitespaces),
            dueDate: dueDate,
            timeOfDay: timeOfDay,
            note: note.trimmingCharacters(in: .whitespaces),
            isRecurring: isRecurring,
            recurringDays: isRecurring ? recurringDays : nil
        )
        GroveStorage.shared.saveCareReminder(reminder)
        onDismiss()
    }
}
