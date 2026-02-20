import SwiftUI

struct AddCustomReminderKindSheet: View {

    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"

    private let iconOptions = [
        "star.fill", "heart.fill", "pills.fill", "scissors", "syringe.fill",
        "pawprint.fill", "leaf.fill", "drop.fill", "flame.fill", "bolt.fill",
        "calendar.badge.clock", "bell.badge.fill", "checkmark.circle.fill",
        "exclamationmark.triangle.fill", "hand.raised.fingers.spread.fill"
    ]

    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        TextField("", text: $name)
                            .placeholder(when: name.isEmpty) {
                                Text("e.g. Flea treatment, Nail trim")
                                    .foregroundColor(AuraPalette.whisperAsh)
                            }
                            .font(AuraFont.cardTitle())
                            .foregroundColor(AuraPalette.boneWhite)
                            .padding(14)
                            .background(AuraPalette.healingCharcoal)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icon")
                            .font(AuraFont.captionWhisper())
                            .foregroundColor(AuraPalette.mistBreath)
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ], spacing: 10) {
                            ForEach(iconOptions, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(
                                            selectedIcon == icon
                                            ? AuraPalette.restingNight
                                            : AuraPalette.mistBreath
                                        )
                                        .frame(width: 56, height: 56)
                                        .background(
                                            selectedIcon == icon
                                            ? AuraPalette.lifeGold
                                            : AuraPalette.healingCharcoal
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(AuraPalette.restingNight.ignoresSafeArea())
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(AuraPalette.mistBreath)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(name.trimmingCharacters(in: .whitespaces), selectedIcon)
                    }
                    .font(AuraFont.cardTitle())
                    .foregroundColor(canSave ? AuraPalette.lifeGold : AuraPalette.whisperAsh)
                    .disabled(!canSave)
                }
            }
        }
    }
}
