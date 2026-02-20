import SwiftUI

// MARK: - Waypoint Placeholder Views
// Full placeholder screens for navigation destinations (Apple rejects stub Text-only views)

struct TrendDetailPlaceholderView: View {
    let axis: WellnessAxis

    var body: some View {
        PlaceholderScreenLayout(
            icon: axis.icon,
            title: "\(axis.displayName) Trend",
            message: "Detailed chart with 7/14/30 day views, averages, and min/max coming soon."
        )
    }
}

struct TrendDetailCustomPlaceholderView: View {
    let axisId: String

    var body: some View {
        let settings = GroveStorage.shared.settings
        let axis = CategoryResolver.axisInfo(axisId: axisId, customAxes: settings.customWellnessAxes)
        PlaceholderScreenLayout(
            icon: axis?.icon ?? "chart.xyaxis.line",
            title: "\(axis?.name ?? "Custom") Trend",
            message: "Detailed chart with 7/14/30 day views coming soon."
        )
    }
}

struct DayDetailPlaceholderView: View {
    let dateKey: String

    var body: some View {
        PlaceholderScreenLayout(
            icon: "calendar.day.timeline.left",
            title: "Day Details",
            message: "Full day card with scales, episodes, and notes coming soon."
        )
    }
}

struct EpisodeDetailPlaceholderView: View {
    let episodeId: UUID

    var body: some View {
        PlaceholderScreenLayout(
            icon: "exclamationmark.bubble.fill",
            title: "Episode Details",
            message: "View and edit existing episodes coming soon."
        )
    }
}

struct CompanionDetailPlaceholderView: View {
    let companionId: UUID

    var body: some View {
        PlaceholderScreenLayout(
            icon: "pawprint.fill",
            title: "Companion Profile",
            message: "Full profile with history, charts, and stats coming soon."
        )
    }
}

// MARK: - Reusable Placeholder Layout

private struct PlaceholderScreenLayout: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundColor(AuraPalette.lifeGold)

                Text(title)
                    .font(AuraFont.heroTitle())
                    .foregroundColor(AuraPalette.boneWhite)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AuraFont.bodyPulse())
                    .foregroundColor(AuraPalette.mistBreath)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Coming in a future update")
                    .font(AuraFont.captionWhisper())
                    .foregroundColor(AuraPalette.whisperAsh)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .withEmberBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
