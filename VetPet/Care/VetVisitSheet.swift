import SwiftUI

struct VetVisitSheet: View {

    let companionId: UUID
    let onDismiss: () -> Void

    @State private var date: Date = Date()
    @State private var vetName: String = ""
    @State private var reason: String = ""
    @State private var notes: String = ""

    var canSave: Bool { !vetName.trimmingCharacters(in: .whitespaces).isEmpty || !reason.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(AuraPalette.lifeGold)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Vet / Clinic")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $vetName)
                            .placeholder(when: vetName.isEmpty) {
                                Text("Vet name or clinic")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reason")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $reason)
                            .placeholder(when: reason.isEmpty) {
                                Text("Checkup, vaccination, etc.")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (optional)")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $notes, axis: .vertical)
                            .placeholder(when: notes.isEmpty) {
                                Text("Diagnosis, prescriptions, etc.")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.bodyPulse())
                            .foregroundColor(AuraPalette.boneWhite)
                            .lineLimit(3...6)
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
            .navigationTitle("Log Vet Visit")
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

    private func save() {
        let visit = VetVisit(
            companionId: companionId,
            date: date,
            vetName: vetName.trimmingCharacters(in: .whitespaces),
            reason: reason.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        GroveStorage.shared.saveVetVisit(visit)
        onDismiss()
    }
}
